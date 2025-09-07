import Foundation
import SpriteKit

// MARK: - Tiled JSON models (CSV, no chunks, orthogonal)
private struct TiledMap: Decodable {
    let width: Int
    let height: Int
    let tilewidth: Int
    let tileheight: Int
    let layers: [TiledLayer]
    let tilesets: [TiledTilesetRef]
}
private struct TiledLayer: Decodable {
    let name: String
    let type: String
    let visible: Bool?
    let opacity: Double?
    let encoding: String?
    let data: String?
}
private struct TiledTilesetRef: Decodable {
    let firstgid: Int
    let source: String?   // .tsx filename when not embedded
    let tilecount: Int?
    let columns: Int?
}

// MARK: - TSX reader (very small XML parser)
private final class TSX: NSObject, XMLParserDelegate {
    var imageSource: String = ""
    var imageWidth: Int = 0
    var imageHeight: Int = 0
    var tileWidth: Int = 16
    var tileHeight: Int = 16
    var spacing: Int = 0
    var margin: Int = 0

    init?(tsxName: String) {
        guard let url = Bundle.main.url(forResource: tsxName.replacingOccurrences(of: ".tsx", with: ""), withExtension: "tsx"),
              let data = try? Data(contentsOf: url) else { return nil }
        super.init()
        let p = XMLParser(data: data)
        p.delegate = self
        _ = p.parse()
    }
    func parser(_ parser: XMLParser, didStartElement name: String, namespaceURI: String?,
                qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if name == "tileset" {
            if let tw = attributeDict["tilewidth"] { tileWidth = Int(tw) ?? tileWidth }
            if let th = attributeDict["tileheight"] { tileHeight = Int(th) ?? tileHeight }
            if let sp = attributeDict["spacing"] { spacing = Int(sp) ?? 0 }
            if let mg = attributeDict["margin"] { margin = Int(mg) ?? 0 }
        } else if name == "image" {
            imageSource = (attributeDict["source"] ?? "").split(separator: "/").last.map(String.init) ?? ""
            imageWidth  = Int(attributeDict["width"]  ?? "0") ?? 0
            imageHeight = Int(attributeDict["height"] ?? "0") ?? 0
        }
    }
}

// MARK: - Build SKTileSet & SKTileMapNodes
struct TiledBuildResult {
    let columns: Int
    let rows: Int
    let tileSize: CGSize
    let layers: [SKTileMapNode]
}

enum TiledLoadError: Error {
    case fileMissing(String)
    case unsupported(String)
}

final class TiledLoader {
    static func build(named mapName: String) throws -> TiledBuildResult {
        guard let url = Bundle.main.url(forResource: mapName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw TiledLoadError.fileMissing("Could not find \(mapName).json in bundle.")
        }
        let decoder = JSONDecoder()
        let map = try decoder.decode(TiledMap.self, from: data)

        guard let setRef = map.tilesets.first else {
            throw TiledLoadError.unsupported("No tileset in map.")
        }

        // tileset can be embedded or external; we support external TSX (recommended)
        var tsx: TSX?
        if let src = setRef.source {
            tsx = TSX(tsxName: src)
        }
        // If embedded, fall back to map tile size; image name must equal "Overworld.png"
        let tileW = tsx?.tileWidth  ?? map.tilewidth
        let tileH = tsx?.tileHeight ?? map.tileheight
        let imageName = tsx?.imageSource.isEmpty == false ? tsx!.imageSource : "Overworld.png"
        let imgW = tsx?.imageWidth  ?? 0
        let imgH = tsx?.imageHeight ?? 0
        let spacing = tsx?.spacing ?? 0
        let margin  = tsx?.margin  ?? 0

        // tilesheet texture
        let baseTexture = SKTexture(imageNamed: imageName)
        baseTexture.filteringMode = .nearest
        guard baseTexture.size() != .zero else {
            throw TiledLoadError.fileMissing("Tilesheet PNG '\(imageName)' not found in bundle.")
        }
        let sheetW = imgW > 0 ? imgW : Int(baseTexture.size().width)
        let sheetH = imgH > 0 ? imgH : Int(baseTexture.size().height)

        let columnsInSheet = (sheetW - 2 * margin + spacing) / (tileW + spacing)
        let rowsInSheet    = (sheetH - 2 * margin + spacing) / (tileH + spacing)
        let totalTiles = max(columnsInSheet * rowsInSheet, 0)

        // Build tile groups for all tile ids present (1..N)
        var groups: [SKTileGroup] = []
        groups.reserveCapacity(totalTiles)
        for id in 1...max(totalTiles, 1) {
            let c = (id - 1) % columnsInSheet
            let r = (id - 1) / columnsInSheet
            let x = margin + c * (tileW + spacing)
            let y = margin + r * (tileH + spacing)

            // SpriteKit texture rect uses unit coordinates with origin at bottom-left
            let rect = CGRect(
                x: CGFloat(x) / CGFloat(sheetW),
                y: 1.0 - CGFloat(y + tileH) / CGFloat(sheetH),
                width: CGFloat(tileW) / CGFloat(sheetW),
                height: CGFloat(tileH) / CGFloat(sheetH)
            )
            let tex = SKTexture(rect: rect, in: baseTexture)
            tex.filteringMode = .nearest

            let def = SKTileDefinition(texture: tex, size: CGSize(width: tileW, height: tileH))
            def.name = "id_\(id)"
            let rule = SKTileGroupRule(adjacency: .adjacencyAll, tileDefinitions: [def])
            let group = SKTileGroup(rules: [rule])
            group.name = "id_\(id)"
            groups.append(group)
        }

        let tileSet = SKTileSet(tileGroups: groups, tileSetType: .grid)
        let tileSize = CGSize(width: tileW, height: tileH)

        // Build each tile layer
        var nodes: [SKTileMapNode] = []
        var z: CGFloat = 0
        for layer in map.layers where layer.type == "tilelayer" {
            guard (layer.encoding ?? "csv").lowercased() == "csv",
                  let csv = layer.data else {
                throw TiledLoadError.unsupported("Layer \(layer.name) must be CSV encoded.")
            }
            let grid = csv
                .split(whereSeparator: { $0 == "," || $0 == "\n" || $0 == "\r" })
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }

            let tm = SKTileMapNode(tileSet: tileSet, columns: map.width, rows: map.height, tileSize: tileSize)
            tm.enableAutomapping = false
            tm.zPosition = z
            z += 10

            for row in 0..<map.height {
                for col in 0..<map.width {
                    let idx = row * map.width + col
                    guard idx < grid.count else { continue }
                    let gid = grid[idx]
                    if gid > 0 {
                        let gIndex = min(gid, groups.count) - 1
                        tm.setTileGroup(groups[gIndex], forColumn: col, row: (map.height - 1 - row))
                    }
                }
            }
            nodes.append(tm)
        }

        return TiledBuildResult(columns: map.width, rows: map.height, tileSize: tileSize, layers: nodes)
    }
}

