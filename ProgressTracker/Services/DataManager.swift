import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var dailyEntries: [DailyCalorieEntry] = []
    @Published var savedFoodItems: [FoodItem] = []
    @Published var weightEntries: [WeightEntry] = []
    @Published var userSettings = UserSettings.shared
    @Published var progressStats = ProgressStats()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadData()
        calculateProgressStats()
    }
    
    // MARK: - Data Persistence
    private func loadData() {
        loadDailyEntries()
        loadSavedFoodItems()
        loadWeightEntries()
        loadUserSettings()
    }
    
    private func loadDailyEntries() {
        if let data = userDefaults.data(forKey: "dailyEntries"),
           let entries = try? JSONDecoder().decode([DailyCalorieEntry].self, from: data) {
            dailyEntries = entries
        }
    }
    
    private func saveDailyEntries() {
        if let data = try? JSONEncoder().encode(dailyEntries) {
            userDefaults.set(data, forKey: "dailyEntries")
        }
    }
    
    private func loadSavedFoodItems() {
        if let data = userDefaults.data(forKey: "savedFoodItems"),
           let items = try? JSONDecoder().decode([FoodItem].self, from: data) {
            savedFoodItems = items
        }
    }
    
    private func saveSavedFoodItems() {
        if let data = try? JSONEncoder().encode(savedFoodItems) {
            userDefaults.set(data, forKey: "savedFoodItems")
        }
    }
    
    private func loadWeightEntries() {
        if let data = userDefaults.data(forKey: "weightEntries"),
           let entries = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            weightEntries = entries
        }
    }
    
    private func saveWeightEntries() {
        if let data = try? JSONEncoder().encode(weightEntries) {
            userDefaults.set(data, forKey: "weightEntries")
        }
    }
    
    private func loadUserSettings() {
        if let data = userDefaults.data(forKey: "userSettings"),
           let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            userSettings = settings
        }
    }
    
    private func saveUserSettings() {
        if let data = try? JSONEncoder().encode(userSettings) {
            userDefaults.set(data, forKey: "userSettings")
        }
    }
    
    // MARK: - Daily Calorie Management
    func getTodaysEntry() -> DailyCalorieEntry {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let entry = dailyEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            return entry
        } else {
            let newEntry = DailyCalorieEntry(date: today)
            dailyEntries.append(newEntry)
            saveDailyEntries()
            return newEntry
        }
    }
    
    func addFoodItem(_ foodItem: FoodItem, to date: Date = Date()) {
        let targetDate = Calendar.current.startOfDay(for: date)
        
        if let index = dailyEntries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }) {
            dailyEntries[index].foodItems.append(foodItem)
        } else {
            let newEntry = DailyCalorieEntry(date: targetDate, foodItems: [foodItem])
            dailyEntries.append(newEntry)
        }
        
        // Also save to reusable items if not already saved
        if !savedFoodItems.contains(where: { $0.name == foodItem.name }) {
            savedFoodItems.append(foodItem)
            saveSavedFoodItems()
        }
        
        saveDailyEntries()
        calculateProgressStats()
    }
    
    func removeFoodItem(_ foodItem: FoodItem, from date: Date = Date()) {
        let targetDate = Calendar.current.startOfDay(for: date)
        
        if let entryIndex = dailyEntries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }),
           let itemIndex = dailyEntries[entryIndex].foodItems.firstIndex(where: { $0.id == foodItem.id }) {
            dailyEntries[entryIndex].foodItems.remove(at: itemIndex)
            saveDailyEntries()
            calculateProgressStats()
        }
    }
    
    // MARK: - Weight Management
    func addWeightEntry(_ weight: Double, date: Date = Date()) {
        let entry = WeightEntry(date: date, weight: weight)
        weightEntries.append(entry)
        weightEntries.sort { $0.date < $1.date }
        saveWeightEntries()
        calculateProgressStats()
    }
    
    // MARK: - Settings Management
    func updateDailyCalorieGoal(_ goal: Int) {
        userSettings.dailyCalorieGoal = goal
        saveUserSettings()
    }
    
    func updateLanguage(_ language: String) {
        userSettings.language = language
        saveUserSettings()
    }
    
    // MARK: - Progress Calculations
    private func calculateProgressStats() {
        calculateAverageCalories()
        calculateWeightChanges()
        calculateStreak()
    }
    
    private func calculateAverageCalories() {
        let now = Date()
        let calendar = Calendar.current
        
        // Weekly average
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let weeklyEntries = dailyEntries.filter { $0.date >= weekAgo }
        progressStats.weeklyAverageCalories = weeklyEntries.isEmpty ? 0 : Double(weeklyEntries.reduce(0) { $0 + $1.totalCalories }) / Double(weeklyEntries.count)
        
        // Monthly average
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let monthlyEntries = dailyEntries.filter { $0.date >= monthAgo }
        progressStats.monthlyAverageCalories = monthlyEntries.isEmpty ? 0 : Double(monthlyEntries.reduce(0) { $0 + $1.totalCalories }) / Double(monthlyEntries.count)
    }
    
    private func calculateWeightChanges() {
        guard weightEntries.count >= 2 else { return }
        
        let sortedEntries = weightEntries.sorted { $0.date < $1.date }
        let latest = sortedEntries.last!
        
        // Weekly change
        if let weekAgoEntry = sortedEntries.last(where: { $0.date <= Calendar.current.date(byAdding: .day, value: -7, to: latest.date) ?? Date() }) {
            progressStats.weeklyWeightChange = latest.weight - weekAgoEntry.weight
        }
        
        // Monthly change
        if let monthAgoEntry = sortedEntries.last(where: { $0.date <= Calendar.current.date(byAdding: .month, value: -1, to: latest.date) ?? Date() }) {
            progressStats.monthlyWeightChange = latest.weight - monthAgoEntry.weight
        }
    }
    
    private func calculateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var currentDate = today
        
        while let entry = dailyEntries.first(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }),
              entry.totalCalories > 0 {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        progressStats.streakDays = streak
    }
}