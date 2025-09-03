import Foundation
import Combine

// MARK: - Impact Models
struct ImpactEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let habitName: String
    let quantity: Double
    let unit: String
    
    // impacts
    let co2SavedKg: Double
    let energySavedKWh: Double
    let waterSavedL: Double
    let wasteDivertedKg: Double
    let plasticSavedKg: Double
    let moneySavedJPY: Double
}

struct ImpactTotals {
    var co2SavedKg: Double = 0
    var energySavedKWh: Double = 0
    var waterSavedL: Double = 0
    var wasteDivertedKg: Double = 0
    var plasticSavedKg: Double = 0
    var moneySavedJPY: Double = 0
}

// MARK: - Assumptions (rough, editable)
struct ImpactAssumptions {
    // Prices
    var electricityJPYPerKWh: Double = 30      // JP typical range ~25–40
    var gasolineJPYPerL: Double = 170          // varies
    var bottleJPY: Double = 120                // disposable bottle price
    var lunchSaveJPY: Double = 400             // bring from home vs takeaway
    
    // Emissions / factors
    var gridCO2KgPerKWh: Double = 0.40         // rough average
    var carCO2KgPerKm: Double = 0.21           // car vs bike/public
    var carFuelLPerKm: Double = 0.07           // ~7L/100km
    var energyPerCarKmKWh: Double = 0.6        // proxy energy
    var dryerKWhPerLoad: Double = 2.5          // typical household dryer
    var bottleCO2Kg: Double = 0.082            // 500ml PET (incl. cap/label)
    var bottlePlasticKg: Double = 0.012        // ~12g plastic per bottle
    var bottleWaterL: Double = 1.9             // manufacturing water per 500ml
    var packagingWasteKgPerLunch: Double = 0.10
    var packagingPlasticKgPerLunch: Double = 0.03
    var lunchCO2Kg: Double = 0.50              // very rough differential
    
    // AC: % energy saved per °C warmer setpoint vs 24°C baseline
    var acPercentPerC: Double = 0.04           // 4% / °C
    var acBasePowerKW: Double = 1.0            // typical wall AC average draw
}

enum HabitKind: Equatable {
    case bike
    case ac(setpointC: Double)
    case bottle
    case lunch
    case hangDry
    case unknown
}

enum TimeFrame {
    case week, month, year, allTime
    
    var dateInterval: DateInterval? {
        let now = Date()
        let cal = Calendar.current
        switch self {
        case .week:
            return DateInterval(start: cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: now))!,
                                end: now)
        case .month:
            return DateInterval(start: cal.date(byAdding: .day, value: -29, to: cal.startOfDay(for: now))!,
                                end: now)
        case .year:
            return DateInterval(start: cal.date(byAdding: .day, value: -364, to: cal.startOfDay(for: now))!,
                                end: now)
        case .allTime:
            return nil
        }
    }
}

// MARK: - Impact Calculator
struct ImpactCalculator {
    var A = ImpactAssumptions()
    
    func kind(for habitName: String) -> HabitKind {
        let s = habitName.lowercased()
        if s.contains("bike/public") || s.contains("bike/public transportation") || s.contains("bike") {
            return .bike
        }
        if s.contains("airconditioner only down to") || s.contains("air conditioner") || s.contains("airconditioner") {
            if let c = extractSetpointC(from: habitName) { return .ac(setpointC: c) }
            return .ac(setpointC: 26.5)
        }
        if s.contains("reusable waterbottle") || s.contains("reusable water bottle") {
            return .bottle
        }
        if s.contains("bring lunch") {
            return .lunch
        }
        if s.contains("hang-dry") || s.contains("hang dry") {
            return .hangDry
        }
        return .unknown
    }
    
    func extractSetpointC(from text: String) -> Double? {
        // find number before "°"
        if let degRange = text.range(of: "°") {
            let prefix = text[..<degRange.lowerBound]
            let nums = prefix.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let val = Double(nums) { return val }
        }
        // fallback: look for trailing number like "26.5"
        let scanner = text.components(separatedBy: CharacterSet(charactersIn: "0123456789.-").inverted).joined()
        return Double(scanner)
    }
    
    // MARK: calculators return a fully-populated ImpactEntry
    func bike(habitName: String, km: Double) -> ImpactEntry {
        let co2 = A.carCO2KgPerKm * km
        let energy = A.energyPerCarKmKWh * km
        let fuelL = A.carFuelLPerKm * km
        let money = fuelL * A.gasolineJPYPerL
        return ImpactEntry(id: UUID(), date: Date(), habitName: habitName, quantity: km, unit: "km",
                           co2SavedKg: co2,
                           energySavedKWh: energy,
                           waterSavedL: 0,
                           wasteDivertedKg: 0,
                           plasticSavedKg: 0,
                           moneySavedJPY: money)
    }
    
    func ac(habitName: String, setpointC: Double, hours: Double) -> ImpactEntry {
        let deltaC = max(0, setpointC - 24.0)
        let kWh = A.acBasePowerKW * (A.acPercentPerC * deltaC) * hours
        let co2 = kWh * A.gridCO2KgPerKWh
        let money = kWh * A.electricityJPYPerKWh
        return ImpactEntry(id: UUID(), date: Date(), habitName: habitName, quantity: hours, unit: "h",
                           co2SavedKg: co2,
                           energySavedKWh: kWh,
                           waterSavedL: 0,
                           wasteDivertedKg: 0,
                           plasticSavedKg: 0,
                           moneySavedJPY: money)
    }
    
    func bottle(habitName: String, count: Int) -> ImpactEntry {
        let c = Double(count)
        let co2 = A.bottleCO2Kg * c
        let water = A.bottleWaterL * c
        let plastic = A.bottlePlasticKg * c
        let money = A.bottleJPY * c
        return ImpactEntry(id: UUID(), date: Date(), habitName: habitName, quantity: c, unit: "bottle(s)",
                           co2SavedKg: co2,
                           energySavedKWh: 0,
                           waterSavedL: water,
                           wasteDivertedKg: 0,
                           plasticSavedKg: plastic,
                           moneySavedJPY: money)
    }
    
    func lunch(habitName: String, meals: Int) -> ImpactEntry {
        let c = Double(meals)
        let co2 = A.lunchCO2Kg * c
        let waste = A.packagingWasteKgPerLunch * c
        let plastic = A.packagingPlasticKgPerLunch * c
        let money = A.lunchSaveJPY * c
        return ImpactEntry(id: UUID(), date: Date(), habitName: habitName, quantity: c, unit: "meal(s)",
                           co2SavedKg: co2,
                           energySavedKWh: 0,
                           waterSavedL: 0,
                           wasteDivertedKg: waste,
                           plasticSavedKg: plastic,
                           moneySavedJPY: money)
    }
    
    func hangDry(habitName: String, loads: Int) -> ImpactEntry {
        let c = Double(loads)
        let kWh = A.dryerKWhPerLoad * c
        let co2 = kWh * A.gridCO2KgPerKWh
        let money = kWh * A.electricityJPYPerKWh
        return ImpactEntry(id: UUID(), date: Date(), habitName: habitName, quantity: c, unit: "load(s)",
                           co2SavedKg: co2,
                           energySavedKWh: kWh,
                           waterSavedL: 0,
                           wasteDivertedKg: 0,
                           plasticSavedKg: 0,
                           moneySavedJPY: money)
    }
    
    func unknown(habitName: String, count: Int) -> ImpactEntry {
        ImpactEntry(id: UUID(), date: Date(), habitName: habitName, quantity: Double(count), unit: "time(s)",
                    co2SavedKg: 0, energySavedKWh: 0, waterSavedL: 0,
                    wasteDivertedKg: 0, plasticSavedKg: 0, moneySavedJPY: 0)
    }
}

// MARK: - Store
@MainActor
final class ImpactStore: ObservableObject {
    static let shared = ImpactStore()
    
    @Published private(set) var entries: [ImpactEntry] = []
    private let calc = ImpactCalculator()
    
    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("impact_log.json")
    }()
    
    private init() { load() }
    
    // Logging helpers
    func logBike(habitName: String, km: Double) {
        append(calc.bike(habitName: habitName, km: km))
    }
    func logAC(habitName: String, setpointC: Double, hours: Double) {
        append(calc.ac(habitName: habitName, setpointC: setpointC, hours: hours))
    }
    func logBottle(habitName: String, count: Int) {
        append(calc.bottle(habitName: habitName, count: count))
    }
    func logLunch(habitName: String, meals: Int) {
        append(calc.lunch(habitName: habitName, meals: meals))
    }
    func logHangDry(habitName: String, loads: Int) {
        append(calc.hangDry(habitName: habitName, loads: loads))
    }
    func logUnknown(habitName: String, count: Int) {
        append(calc.unknown(habitName: habitName, count: count))
    }
    
    private func append(_ entry: ImpactEntry) {
        entries.append(entry)
        save()
    }
    
    // Query
    func entries(in timeframe: TimeFrame) -> [ImpactEntry] {
        guard let interval = timeframe.dateInterval else { return entries }
        return entries.filter { interval.contains($0.date) }
    }
    
    func totals(in timeframe: TimeFrame) -> ImpactTotals {
        reduceTotals(entries: entries(in: timeframe))
    }
    
    func totalsAll() -> ImpactTotals { reduceTotals(entries: entries) }
    
    private func reduceTotals(entries: [ImpactEntry]) -> ImpactTotals {
        entries.reduce(into: ImpactTotals()) { t, e in
            t.co2SavedKg += e.co2SavedKg
            t.energySavedKWh += e.energySavedKWh
            t.waterSavedL += e.waterSavedL
            t.wasteDivertedKg += e.wasteDivertedKg
            t.plasticSavedKg += e.plasticSavedKg
            t.moneySavedJPY += e.moneySavedJPY
        }
    }
    
    // Per-habit rollups + streak
    struct HabitRollup: Identifiable {
        let id = UUID()
        let habitName: String
        let daysActive: Int
        let completionRate: Double    // active days / timeframe days
        let currentStreakDays: Int
        let totals: ImpactTotals
    }
    
    func habitRollups(in timeframe: TimeFrame) -> [HabitRollup] {
        let list = entries(in: timeframe)
        let grouped = Dictionary(grouping: list, by: { $0.habitName })
        let daysInRange: Int = {
            guard let interval = timeframe.dateInterval else {
                // avoid divide-by-zero; treat all-time as 365 for rate
                return 365
            }
            let cal = Calendar.current
            let days = cal.dateComponents([(.day)], from: interval.start, to: interval.end).day ?? 0
            return max(1, days + 1)
        }()
        
        return grouped.map { (name, items) in
            let uniqueDays = Set(items.map { Calendar.current.startOfDay(for: $0.date) })
            let completion = Double(uniqueDays.count) / Double(daysInRange)
            let streak = streakDays(for: name)
            let totals = reduceTotals(entries: items)
            return HabitRollup(habitName: name, daysActive: uniqueDays.count,
                               completionRate: min(1, completion),
                               currentStreakDays: streak,
                               totals: totals)
        }.sorted { $0.habitName < $1.habitName }
    }
    
    private func streakDays(for habitName: String) -> Int {
        let cal = Calendar.current
        let daysSet = Set(entries.filter { $0.habitName == habitName }
                            .map { cal.startOfDay(for: $0.date) })
        var days = 0
        var cursor = cal.startOfDay(for: Date())
        while daysSet.contains(cursor) {
            days += 1
            cursor = cal.date(byAdding: .day, value: -1, to: cursor)!
        }
        return days
    }
    
    // Persistence
    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([ImpactEntry].self, from: data)
            entries = decoded
        } catch {
            print("ImpactStore load error:", error)
            entries = []
        }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("ImpactStore save error:", error)
        }
    }
}

