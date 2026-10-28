import Foundation

struct BrinzaIngredientBit: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var unitLabel: String
    var baseCount: Int
    var aisle: String
}

struct BrinzaRecipeCard: Identifiable, Hashable {
    var id: String
    var title: String
    var styleTag: String
    var minutes: Int
    var stillKey: String
    var blurb: String
    var steps: [String]
    var ingredients: [BrinzaIngredientBit]
}

struct BrinzaPantryBit: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var aisle: String
    var unitLabel: String
    var count: Int
    var packed: Bool
    var fromDish: String
}

struct BrinzaDaySlot: Identifiable, Hashable, Codable {
    var id: UUID
    var weekdayIndex: Int
    var recipeID: String
    var portions: Int
}

struct BrinzaCookTick: Identifiable, Hashable, Codable {
    var id: UUID
    var dishName: String
    var durationSeconds: Int
    var remainingSeconds: Int
    var running: Bool
    var finished: Bool
    var pausedByLeave: Bool
}

struct BrinzaCookMemory: Identifiable, Hashable, Codable {
    var id: UUID
    var dishName: String
    var finishedOn: Date
    var plannedSeconds: Int
}

struct BrinzaTasteMark: Identifiable, Hashable, Codable {
    var id: String
    var reaction: String
    var notedOn: Date
}

enum BrinzaTaste {
    static let again = "again"
    static let fine = "fine"
    static let skip = "skip"
}

enum BrinzaRoute: Hashable {
    case recipe(String)
    case setup
}

struct BrinzaCookToken: Identifiable, Hashable {
    let id: UUID
}

enum BrinzaLane: String, CaseIterable, Identifiable {
    case ideas, week, pantry, timers, log
    var id: String { rawValue }
    var brinzaTitle: String {
        switch self {
        case .ideas: return "Ideas"
        case .week: return "Week"
        case .pantry: return "Pantry"
        case .timers: return "Timers"
        case .log: return "Log"
        }
    }
}

enum BrinzaWeekName {
    static let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    static var todayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }
}

enum BrinzaAisleRack {
    static let order = ["Produce", "Grains", "Proteins", "Dairy", "Pantry", "Other"]
}

enum BrinzaStillRack {
    static let bowl = "brinzaRoastBowl"
    static let herbs = "brinzaHerbLinen"
    static let board = "brinzaCitrusBoard"
    static let noodles = "brinzaNoodleSteam"
}

enum BrinzaClockText {
    static func face(_ seconds: Int) -> String {
        let safe = max(0, seconds)
        return String(format: "%d:%02d", safe / 60, safe % 60)
    }

    static func stamp(_ date: Date) -> String {
        formatter.string(from: date)
    }

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

enum BrinzaPantryModelsKelvDrift {
    static func brinzaPantryModelsKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "eeefcqdotdwekp-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 35) &+ Int(scalar.value)
        }
    }
}
