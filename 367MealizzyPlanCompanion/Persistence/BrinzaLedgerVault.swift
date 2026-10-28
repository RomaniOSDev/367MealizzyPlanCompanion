import Foundation
import UIKit

extension Notification.Name {
    static let dataReset = Notification.Name("brinzaQelvDataReset")
}

enum BrinzaVaultKey {
    static let seen = "brinza.qelv.seenWelcome"
    static let hints = "brinza.qelv.showHints"
    static let favorites = "brinza.qelv.favorites"
    static let category = "brinza.qelv.category"
    static let portions = "brinza.qelv.portions"
    static let ownership = "brinza.qelv.ownership"
    static let pantry = "brinza.qelv.pantry"
    static let slots = "brinza.qelv.slots"
    static let ticks = "brinza.qelv.ticks"
    static let log = "brinza.qelv.log"
    static let lastActivity = "brinza.qelv.lastActivity"
    static let tickRecipe = "brinza.qelv.tickRecipe"
    static let tickStep = "brinza.qelv.tickStep"
    static let memoryRecipe = "brinza.qelv.memoryRecipe"
    static let taste = "brinza.qelv.taste"
}

@MainActor
final class BrinzaLedgerVault: ObservableObject {
    @Published var hasSeenOnboarding: Bool
    @Published var showHints: Bool
    @Published var favoriteRecipes: [String]
    @Published var lastBrowsedCategory: String
    @Published var defaultPortions: Int
    @Published var ingredientOwnership: [String: Bool]
    @Published var pantry: [BrinzaPantryBit]
    @Published var daySlots: [BrinzaDaySlot]
    @Published var cookTicks: [BrinzaCookTick]
    @Published var cookLog: [BrinzaCookMemory]
    @Published var lastActivityDate: Date?
    @Published var tickRecipe: [String: String]
    @Published var tickStep: [String: Int]
    @Published var memoryRecipe: [String: String]
    @Published var tasteMarks: [BrinzaTasteMark]
    @Published var brinzaBanner: String?
    @Published var brinzaFocusLane: BrinzaLane?

    private var brinzaFlashTask: Task<Void, Never>?
    private var tickHandle: Timer?
    private let brinzaDefaults = UserDefaults.standard

    init() {
        hasSeenOnboarding = brinzaDefaults.bool(forKey: BrinzaVaultKey.seen)
        if brinzaDefaults.object(forKey: BrinzaVaultKey.hints) == nil {
            showHints = true
        } else {
            showHints = brinzaDefaults.bool(forKey: BrinzaVaultKey.hints)
        }
        favoriteRecipes = Self.brinzaDecode([String].self, key: BrinzaVaultKey.favorites, defaults: brinzaDefaults) ?? []
        lastBrowsedCategory = brinzaDefaults.string(forKey: BrinzaVaultKey.category) ?? "All"
        let storedPortions = brinzaDefaults.integer(forKey: BrinzaVaultKey.portions)
        defaultPortions = storedPortions == 0 ? 1 : min(4, max(1, storedPortions))
        ingredientOwnership = Self.brinzaDecode([String: Bool].self, key: BrinzaVaultKey.ownership, defaults: brinzaDefaults) ?? [:]
        pantry = Self.brinzaDecode([BrinzaPantryBit].self, key: BrinzaVaultKey.pantry, defaults: brinzaDefaults) ?? []
        daySlots = Self.brinzaDecode([BrinzaDaySlot].self, key: BrinzaVaultKey.slots, defaults: brinzaDefaults) ?? []
        cookTicks = Self.brinzaDecode([BrinzaCookTick].self, key: BrinzaVaultKey.ticks, defaults: brinzaDefaults) ?? []
        cookLog = Self.brinzaDecode([BrinzaCookMemory].self, key: BrinzaVaultKey.log, defaults: brinzaDefaults) ?? []
        lastActivityDate = Self.brinzaDecode(Date.self, key: BrinzaVaultKey.lastActivity, defaults: brinzaDefaults)
        tickRecipe = Self.brinzaDecode([String: String].self, key: BrinzaVaultKey.tickRecipe, defaults: brinzaDefaults) ?? [:]
        tickStep = Self.brinzaDecode([String: Int].self, key: BrinzaVaultKey.tickStep, defaults: brinzaDefaults) ?? [:]
        memoryRecipe = Self.brinzaDecode([String: String].self, key: BrinzaVaultKey.memoryRecipe, defaults: brinzaDefaults) ?? [:]
        tasteMarks = Self.brinzaDecode([BrinzaTasteMark].self, key: BrinzaVaultKey.taste, defaults: brinzaDefaults) ?? []
        brinzaSettleAfterLaunch()
    }

    func brinzaMarkWelcomeDone() {
        hasSeenOnboarding = true
        brinzaPersist()
    }

    func brinzaDismissHints() {
        showHints = false
        brinzaPersist()
    }

    func brinzaToggleFavorite(_ id: String) {
        if let index = favoriteRecipes.firstIndex(of: id) {
            favoriteRecipes.remove(at: index)
            brinzaFlash("Removed from saved ideas.")
        } else {
            favoriteRecipes.append(id)
            brinzaPulse()
            brinzaFlash("Saved with the ideas you like.")
        }
        brinzaTouch()
        brinzaPersist()
    }

    func brinzaSetCategory(_ name: String) {
        lastBrowsedCategory = name
        brinzaDefaults.set(name, forKey: BrinzaVaultKey.category)
    }

    func brinzaSetPortions(_ value: Int) {
        defaultPortions = min(4, max(1, value))
        brinzaDefaults.set(defaultPortions, forKey: BrinzaVaultKey.portions)
    }

    func brinzaToggleOwned(_ ingredientID: String) {
        ingredientOwnership[ingredientID] = ingredientOwnership[ingredientID] == true ? false : true
        brinzaTouch()
        brinzaPersist()
    }

    func brinzaInKitchen(_ bit: BrinzaIngredientBit) -> Bool {
        if ingredientOwnership[bit.id] == true { return true }
        let name = bit.name.lowercased()
        return pantry.contains { $0.packed && $0.name.lowercased() == name }
    }

    func brinzaOnShoppingList(_ bit: BrinzaIngredientBit) -> Bool {
        let name = bit.name.lowercased()
        return pantry.contains { $0.packed == false && $0.name.lowercased() == name }
    }

    func brinzaMissingCount(_ recipe: BrinzaRecipeCard) -> Int {
        recipe.ingredients.filter { brinzaInKitchen($0) == false && brinzaOnShoppingList($0) == false }.count
    }

    func brinzaGapCount(_ recipe: BrinzaRecipeCard) -> Int {
        recipe.ingredients.filter { brinzaInKitchen($0) == false }.count
    }

    func brinzaSendRecipe(_ recipe: BrinzaRecipeCard, portions: Int) {
        var added: [String] = []
        for bit in recipe.ingredients {
            if brinzaInKitchen(bit) || brinzaOnShoppingList(bit) { continue }
            brinzaMerge(name: bit.name, aisle: bit.aisle, unit: bit.unitLabel, count: bit.baseCount * portions, dish: recipe.title)
            added.append(bit.name)
        }
        brinzaTouch()
        brinzaPersist()
        if added.isEmpty {
            brinzaFlash("Nothing new to add. Those ingredients are already in the kitchen or on the pantry list.")
        } else {
            brinzaPulse()
            let preview = added.prefix(3).joined(separator: ", ")
            let extra = added.count > 3 ? " +\(added.count - 3)" : ""
            brinzaFlash("Added \(added.count) to the pantry: \(preview)\(extra).")
            brinzaFocusLane = .pantry
        }
    }

    func brinzaPourWeek() {
        if daySlots.isEmpty {
            brinzaFlash("Place a meal on a day first.")
            return
        }
        var added = 0
        for slot in daySlots {
            guard let recipe = BrinzaRecipeAtlas.brinzaFind(slot.recipeID) else { continue }
            for bit in recipe.ingredients where brinzaInKitchen(bit) == false && brinzaOnShoppingList(bit) == false {
                brinzaMerge(name: bit.name, aisle: bit.aisle, unit: bit.unitLabel, count: bit.baseCount * slot.portions, dish: recipe.title)
                added += 1
            }
        }
        brinzaTouch()
        brinzaPersist()
        if added == 0 {
            brinzaFlash("Nothing new to add from the week.")
        } else {
            brinzaPulse()
            brinzaFlash("Pantry updated from the week.")
            brinzaFocusLane = .pantry
        }
    }

    func brinzaPlace(recipeID: String, weekday: Int, portions: Int) {
        if let index = daySlots.firstIndex(where: { $0.weekdayIndex == weekday }) {
            daySlots[index].recipeID = recipeID
            daySlots[index].portions = portions
        } else {
            daySlots.append(BrinzaDaySlot(id: UUID(), weekdayIndex: weekday, recipeID: recipeID, portions: portions))
        }
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
        brinzaFlash("Meal placed on \(BrinzaWeekName.days[weekday]).")
    }

    func brinzaFillEmptyDays() {
        let open = BrinzaWeekName.days.indices.filter { index in
            daySlots.contains { $0.weekdayIndex == index } == false
        }
        if open.isEmpty {
            brinzaFlash("Every day already has a plate.")
            return
        }
        var used = Set(daySlots.map(\.recipeID))
        var placed = 0
        for index in open {
            guard let recipe = brinzaNextPlate(excluding: used) else { break }
            used.insert(recipe.id)
            daySlots.append(BrinzaDaySlot(id: UUID(), weekdayIndex: index, recipeID: recipe.id, portions: defaultPortions))
            placed += 1
        }
        guard placed > 0 else {
            brinzaFlash("Save an idea or mark one you would make again.")
            return
        }
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
        brinzaFlash("Filled \(placed) empty day\(placed == 1 ? "" : "s").")
    }

    func brinzaClearDay(_ weekday: Int) {
        daySlots.removeAll { $0.weekdayIndex == weekday }
        brinzaTouch()
        brinzaPersist()
        brinzaFlash("\(BrinzaWeekName.days[weekday]) cleared.")
    }

    func brinzaSavePantry(_ bit: BrinzaPantryBit, isNew: Bool) {
        if let index = pantry.firstIndex(where: { $0.id == bit.id }) {
            pantry[index] = bit
        } else {
            pantry.append(bit)
        }
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
        brinzaFlash(isNew ? "Pantry item added." : "Pantry item updated.")
    }

    func brinzaDeletePantry(_ id: UUID) {
        pantry.removeAll { $0.id == id }
        brinzaTouch()
        brinzaPersist()
        brinzaFlash("Pantry item removed.")
    }

    func brinzaTogglePacked(_ id: UUID) {
        guard let index = pantry.firstIndex(where: { $0.id == id }) else { return }
        pantry[index].packed.toggle()
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
    }

    func brinzaStartTimer(name: String, minutes: Int) {
        let seconds = minutes * 60
        cookTicks.insert(BrinzaCookTick(
            id: UUID(),
            dishName: name,
            durationSeconds: seconds,
            remainingSeconds: seconds,
            running: true,
            finished: false,
            pausedByLeave: false
        ), at: 0)
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
        brinzaFlash("Timer started for \(name).")
        brinzaSyncTicker()
    }

    @discardableResult
    func brinzaStartCook(_ recipe: BrinzaRecipeCard) -> UUID {
        if let existing = brinzaLiveCook(recipe.id) {
            return existing.id
        }
        let id = UUID()
        let seconds = recipe.minutes * 60
        cookTicks.insert(BrinzaCookTick(
            id: id,
            dishName: recipe.title,
            durationSeconds: seconds,
            remainingSeconds: seconds,
            running: true,
            finished: false,
            pausedByLeave: false
        ), at: 0)
        tickRecipe[id.uuidString] = recipe.id
        tickStep[id.uuidString] = 0
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
        brinzaFlash("Timer started for \(recipe.title).")
        brinzaSyncTicker()
        return id
    }

    func brinzaLiveCook(_ recipeID: String) -> BrinzaCookTick? {
        cookTicks.first { $0.finished == false && tickRecipe[$0.id.uuidString] == recipeID }
    }

    func brinzaStep(for tickID: UUID) -> Int {
        tickStep[tickID.uuidString] ?? 0
    }

    func brinzaSetStep(_ tickID: UUID, _ step: Int) {
        tickStep[tickID.uuidString] = max(0, step)
        brinzaPersist()
    }

    func brinzaTaste(for recipeID: String) -> String? {
        tasteMarks.first { $0.id == recipeID }?.reaction
    }

    func brinzaSetTaste(recipeID: String, reaction: String) {
        tasteMarks.removeAll { $0.id == recipeID }
        tasteMarks.insert(BrinzaTasteMark(id: recipeID, reaction: reaction, notedOn: Date()), at: 0)
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
        switch reaction {
        case BrinzaTaste.again:
            brinzaFlash("Saved. This one can come back next week.")
        case BrinzaTaste.skip:
            brinzaFlash("Noted. Week fill will skip this one.")
        default:
            brinzaFlash("Saved how it went.")
        }
    }

    func brinzaRecipeID(for memory: BrinzaCookMemory) -> String? {
        if let stored = memoryRecipe[memory.id.uuidString] { return stored }
        return BrinzaRecipeAtlas.cards.first { $0.title == memory.dishName }?.id
    }

    func brinzaStreakCount() -> Int {
        let calendar = Calendar.current
        let days = Set(cookLog.map { calendar.startOfDay(for: $0.finishedOn) })
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
        var cursor: Date
        if days.contains(today) {
            cursor = today
        } else if days.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }
        var count = 0
        while days.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    func brinzaCookedToday() -> Bool {
        cookLog.contains { Calendar.current.isDateInToday($0.finishedOn) }
    }

    func brinzaCookedThisWeek(_ recipeID: String) -> Bool {
        let calendar = Calendar.current
        return cookLog.contains { memory in
            guard brinzaRecipeID(for: memory) == recipeID else { return false }
            return calendar.isDate(memory.finishedOn, equalTo: Date(), toGranularity: .weekOfYear)
                && calendar.isDate(memory.finishedOn, equalTo: Date(), toGranularity: .yearForWeekOfYear)
        }
    }

    func brinzaWeekCookedCount() -> Int {
        let cooked = Set(daySlots.map(\.recipeID).filter { brinzaCookedThisWeek($0) })
        return cooked.count
    }

    func brinzaReadyCount() -> Int {
        BrinzaRecipeAtlas.cards.filter { brinzaGapCount($0) == 0 }.count
    }

    func brinzaReturnCaption() -> String {
        let streak = brinzaStreakCount()
        if let slot = daySlots.first(where: { $0.weekdayIndex == BrinzaWeekName.todayIndex }),
           let recipe = BrinzaRecipeAtlas.brinzaFind(slot.recipeID) {
            if brinzaCookedThisWeek(recipe.id) {
                return "\(BrinzaWeekName.days[BrinzaWeekName.todayIndex]) · \(recipe.title) is already cooked."
            }
            if streak > 1 && brinzaCookedToday() == false {
                return "Tonight is \(recipe.title). Cook it to keep a \(streak)-day streak."
            }
            return "Tonight is \(recipe.title)."
        }
        if streak > 0 && brinzaCookedToday() == false {
            return "Cook today to keep a \(streak)-day streak."
        }
        let ready = brinzaReadyCount()
        if ready > 0 {
            return "\(ready) idea\(ready == 1 ? "" : "s") you can cook with what you have."
        }
        return "Plan tonight, shop the gaps, then cook."
    }

    func brinzaSuggestTonight() -> BrinzaRecipeCard? {
        brinzaNextPlate(excluding: [])
    }

    func brinzaSaveTick(_ tick: BrinzaCookTick) {
        if let index = cookTicks.firstIndex(where: { $0.id == tick.id }) {
            cookTicks[index] = tick
        } else {
            cookTicks.insert(tick, at: 0)
        }
        brinzaTouch()
        brinzaPersist()
        brinzaSyncTicker()
        brinzaFlash("Timer saved.")
    }

    func brinzaSetRunning(_ id: UUID, running: Bool) {
        guard let index = cookTicks.firstIndex(where: { $0.id == id }) else { return }
        guard cookTicks[index].finished == false else { return }
        cookTicks[index].running = running
        if running { cookTicks[index].pausedByLeave = false }
        brinzaPersist()
        brinzaSyncTicker()
    }

    func brinzaMarkReady(_ id: UUID) {
        guard let index = cookTicks.firstIndex(where: { $0.id == id }) else { return }
        guard cookTicks[index].finished == false else { return }
        cookTicks[index].running = false
        cookTicks[index].finished = true
        cookTicks[index].remainingSeconds = 0
        cookTicks[index].pausedByLeave = false
        brinzaRemember(cookTicks[index])
        brinzaTouch()
        brinzaPersist()
        brinzaPulse()
        brinzaFlash("Marked ready and saved to the log.")
        brinzaSyncTicker()
    }

    func brinzaDiscardTick(_ id: UUID) {
        cookTicks.removeAll { $0.id == id }
        tickRecipe[id.uuidString] = nil
        tickStep[id.uuidString] = nil
        brinzaPersist()
        brinzaSyncTicker()
        brinzaFlash("Timer removed.")
    }

    func brinzaDeleteMemory(_ id: UUID) {
        cookLog.removeAll { $0.id == id }
        memoryRecipe[id.uuidString] = nil
        brinzaTouch()
        brinzaPersist()
    }

    func brinzaPauseForLeave() {
        var changed = false
        for index in cookTicks.indices where cookTicks[index].running && cookTicks[index].finished == false {
            cookTicks[index].running = false
            cookTicks[index].pausedByLeave = true
            changed = true
        }
        tickHandle?.invalidate()
        tickHandle = nil
        if changed { brinzaPersist() }
    }

    func brinzaResetAll() {
        tickHandle?.invalidate()
        tickHandle = nil
        hasSeenOnboarding = false
        showHints = true
        favoriteRecipes = []
        lastBrowsedCategory = "All"
        defaultPortions = 1
        ingredientOwnership = [:]
        pantry = []
        daySlots = []
        cookTicks = []
        cookLog = []
        lastActivityDate = nil
        tickRecipe = [:]
        tickStep = [:]
        memoryRecipe = [:]
        tasteMarks = []
        brinzaBanner = nil
        brinzaFocusLane = nil
        brinzaPersist()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func brinzaFlash(_ text: String) {
        brinzaBanner = text
        brinzaFlashTask?.cancel()
        brinzaFlashTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_200_000_000)
            guard Task.isCancelled == false else { return }
            self.brinzaBanner = nil
        }
    }

    private func brinzaSettleAfterLaunch() {
        var changed = false
        for index in cookTicks.indices where cookTicks[index].running {
            cookTicks[index].running = false
            cookTicks[index].pausedByLeave = true
            changed = true
        }
        if changed { brinzaPersist() }
    }

    private func brinzaAdvanceOneSecond() {
        var changed = false
        for index in cookTicks.indices {
            guard cookTicks[index].running, cookTicks[index].finished == false else { continue }
            changed = true
            if cookTicks[index].remainingSeconds <= 1 {
                cookTicks[index].remainingSeconds = 0
                cookTicks[index].running = false
                cookTicks[index].finished = true
                cookTicks[index].pausedByLeave = false
                brinzaRemember(cookTicks[index])
                brinzaPulse()
                brinzaFlash("\(cookTicks[index].dishName) is ready.")
            } else {
                cookTicks[index].remainingSeconds -= 1
            }
        }
        if changed { brinzaPersist() }
        brinzaSyncTicker()
    }

    private func brinzaSyncTicker() {
        let needs = cookTicks.contains { $0.running && $0.finished == false }
        if needs && tickHandle == nil {
            tickHandle = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.brinzaAdvanceOneSecond()
                }
            }
        } else if needs == false {
            tickHandle?.invalidate()
            tickHandle = nil
        }
    }

    private func brinzaRemember(_ tick: BrinzaCookTick) {
        let memoryID = UUID()
        cookLog.insert(BrinzaCookMemory(
            id: memoryID,
            dishName: tick.dishName,
            finishedOn: Date(),
            plannedSeconds: tick.durationSeconds
        ), at: 0)
        if let recipeID = tickRecipe[tick.id.uuidString] {
            memoryRecipe[memoryID.uuidString] = recipeID
        }
    }

    private func brinzaNextPlate(excluding used: Set<String>) -> BrinzaRecipeCard? {
        let ranked = BrinzaRecipeAtlas.cards.sorted { lhs, rhs in
            brinzaPlateScore(lhs) > brinzaPlateScore(rhs)
        }
        return ranked.first { used.contains($0.id) == false && brinzaTaste(for: $0.id) != BrinzaTaste.skip }
            ?? ranked.first { used.contains($0.id) == false }
    }

    private func brinzaPlateScore(_ card: BrinzaRecipeCard) -> Int {
        var score = 0
        if brinzaTaste(for: card.id) == BrinzaTaste.again { score += 6 }
        if favoriteRecipes.contains(card.id) { score += 4 }
        if brinzaGapCount(card) == 0 { score += 3 }
        if brinzaTaste(for: card.id) == BrinzaTaste.skip { score -= 8 }
        if card.styleTag == "Quick" { score += 1 }
        return score
    }

    private func brinzaMerge(name: String, aisle: String, unit: String, count: Int, dish: String) {
        if let index = pantry.firstIndex(where: { $0.name == name && $0.unitLabel == unit && $0.packed == false }) {
            pantry[index].count += count
            if pantry[index].fromDish.contains(dish) == false {
                pantry[index].fromDish = pantry[index].fromDish.isEmpty ? dish : pantry[index].fromDish + ", " + dish
            }
        } else {
            pantry.append(BrinzaPantryBit(
                id: UUID(),
                name: name,
                aisle: aisle,
                unitLabel: unit,
                count: count,
                packed: false,
                fromDish: dish
            ))
        }
    }

    private func brinzaTouch() {
        lastActivityDate = Date()
    }

    private func brinzaPulse() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    private func brinzaPersist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        func pack<T: Encodable>(_ value: T, _ key: String) {
            if let data = try? encoder.encode(value) {
                brinzaDefaults.set(data, forKey: key)
            }
        }
        brinzaDefaults.set(hasSeenOnboarding, forKey: BrinzaVaultKey.seen)
        brinzaDefaults.set(showHints, forKey: BrinzaVaultKey.hints)
        brinzaDefaults.set(lastBrowsedCategory, forKey: BrinzaVaultKey.category)
        brinzaDefaults.set(defaultPortions, forKey: BrinzaVaultKey.portions)
        pack(favoriteRecipes, BrinzaVaultKey.favorites)
        pack(ingredientOwnership, BrinzaVaultKey.ownership)
        pack(pantry, BrinzaVaultKey.pantry)
        pack(daySlots, BrinzaVaultKey.slots)
        pack(cookTicks, BrinzaVaultKey.ticks)
        pack(cookLog, BrinzaVaultKey.log)
        pack(tickRecipe, BrinzaVaultKey.tickRecipe)
        pack(tickStep, BrinzaVaultKey.tickStep)
        pack(memoryRecipe, BrinzaVaultKey.memoryRecipe)
        pack(tasteMarks, BrinzaVaultKey.taste)
        if let lastActivityDate {
            pack(lastActivityDate, BrinzaVaultKey.lastActivity)
        } else {
            brinzaDefaults.removeObject(forKey: BrinzaVaultKey.lastActivity)
        }
    }

    private static func brinzaDecode<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try? decoder.decode(type, from: data)
    }
}

enum BrinzaLedgerVaultKelvDrift {
    static func brinzaLedgerVaultKelvDriftFold(_ basis: Int) -> Int {
        let ribbon = "lcjawvtiwetyco-kelv"
        return ribbon.unicodeScalars.reduce(basis) { partial, scalar in
            (partial &* 29) &+ Int(scalar.value)
        }
    }
}
