import SwiftUI
import SpriteKit
import UIKit

// MARK: - Scene with pan / pinch / tap-to-place
final class TiledScene: SKScene {
    private let world = SKNode()
    private let camNode = SKCameraNode()
    private(set) var firstMap: SKTileMapNode?
    private var minZoom: CGFloat = 0.5
    private var maxZoom: CGFloat = 4.0

    override init() {
        super.init(size: .zero)
        scaleMode = .resizeFill
        backgroundColor = .clear
        addChild(world)
        camera = camNode
        addChild(camNode)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func load(mapName: String, displayScale: CGFloat) throws {
        world.removeAllChildren()
        let result = try TiledLoader.build(named: mapName)

        for (i, layer) in result.layers.enumerated() {
            layer.name = "Layer_\(i)"
            world.addChild(layer)
            if i == 0 { firstMap = layer }
        }
        world.setScale(displayScale)
        camNode.position = .zero
    }

    // MARK: gestures
    func handlePan(delta: CGPoint) {
        // UIKit: +x right, +y down; SpriteKit: +y up
        camNode.position.x -= delta.x / world.xScale
        camNode.position.y += delta.y / world.yScale
    }
    func handlePinch(scale: CGFloat) {
        var s = world.xScale * scale
        s = max(minZoom, min(maxZoom, s))
        world.setScale(s)
    }

    // MARK: tap-to-place
    func place(at viewPoint: CGPoint, in view: SKView) {
        guard let map = firstMap else { return }
        let scenePoint = convertPoint(fromView: viewPoint)
        let local = map.convert(scenePoint, from: self)

        let tw = map.tileSize.width
        let th = map.tileSize.height
        let cols = map.numberOfColumns
        let rows = map.numberOfRows

        let halfW = CGFloat(cols) * tw / 2
        let halfH = CGFloat(rows) * th / 2

        let col = Int((local.x + halfW) / tw)
        let row = Int((halfH - local.y) / th)

        guard col >= 0, col < cols, row >= 0, row < rows else { return }

        let p = map.centerOfTile(atColumn: col, row: row)

        // Try sprite from Assets named "tree_1", else draw a placeholder square
        if let _ = UIImage(named: "tree_1") {
            let n = SKSpriteNode(imageNamed: "tree_1")
            n.size = CGSize(width: tw, height: th)
            n.position = p
            n.zPosition = 1000
            map.addChild(n)
        } else {
            let n = SKShapeNode(rectOf: CGSize(width: tw * 0.9, height: th * 0.9), cornerRadius: 2)
            n.fillColor = .systemGreen
            n.strokeColor = .black
            n.lineWidth = 1
            n.position = p
            n.zPosition = 1000
            map.addChild(n)
        }
    }
}

// MARK: - UIViewRepresentable that hosts SKView + gestures
struct InteractiveTiledWorldView: UIViewRepresentable {
    let mapName: String
    var displayScale: CGFloat = 3

    func makeUIView(context: Context) -> SKView {
        let v = SKView()
        v.ignoresSiblingOrder = true
        let scene = context.coordinator.scene
        v.presentScene(scene)

        // Load map
        do { try scene.load(mapName: mapName, displayScale: displayScale) }
        catch { print("Tiled load error:", error) }

        // Pinch
        let pinch = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onPinch(_:)))
        // Pan
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onPan(_:)))
        pan.maximumNumberOfTouches = 1
        // Tap
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onTap(_:)))

        v.addGestureRecognizer(pinch)
        v.addGestureRecognizer(pan)
        v.addGestureRecognizer(tap)
        return v
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        // no-op
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject {
        let scene = TiledScene()

        @objc func onPinch(_ rec: UIPinchGestureRecognizer) {
            guard let view = rec.view as? SKView else { return }
            if rec.state == .changed {
                scene.handlePinch(scale: rec.scale)
                rec.scale = 1
            } else if rec.state == .ended {
                // ensure final clamp
                scene.handlePinch(scale: 1)
            }
            view.setNeedsDisplay()
        }

        @objc func onPan(_ rec: UIPanGestureRecognizer) {
            guard let view = rec.view as? SKView else { return }
            let delta = rec.translation(in: view)
            scene.handlePan(delta: delta)
            rec.setTranslation(.zero, in: view)
        }

        @objc func onTap(_ rec: UITapGestureRecognizer) {
            guard let view = rec.view as? SKView else { return }
            let pt = rec.location(in: view)
            scene.place(at: pt, in: view)
        }
    }
}

