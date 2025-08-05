import Foundation

// MARK: - Food Models
struct Dish: Codable, Identifiable {
    let id = UUID()
    let originalName: String
    let translatedName: String
    let calories: String
    let protein: String
    let carbs: String
    let fat: String
    let dietaryTags: [String]
    
    var caloriesInt: Int {
        return Int(calories.replacingOccurrences(of: " kcal", with: "").replacingOccurrences(of: "N/A", with: "0")) ?? 0
    }
    
    var proteinInt: Int {
        return Int(protein.replacingOccurrences(of: "g", with: "").replacingOccurrences(of: "N/A", with: "0")) ?? 0
    }
    
    var carbsInt: Int {
        return Int(carbs.replacingOccurrences(of: "g", with: "").replacingOccurrences(of: "N/A", with: "0")) ?? 0
    }
    
    var fatInt: Int {
        return Int(fat.replacingOccurrences(of: "g", with: "").replacingOccurrences(of: "N/A", with: "0")) ?? 0
    }
}

// MARK: - Calorie Tracking Models
struct FoodItem: Codable, Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let dietaryTags: [String]
    var dateAdded: Date = Date()
    
    init(name: String, calories: Int, protein: Int, carbs: Int, fat: Int, dietaryTags: [String] = []) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.dietaryTags = dietaryTags
    }
    
    init(from dish: Dish) {
        self.name = dish.translatedName.isEmpty ? dish.originalName : dish.translatedName
        self.calories = dish.caloriesInt
        self.protein = dish.proteinInt
        self.carbs = dish.carbsInt
        self.fat = dish.fatInt
        self.dietaryTags = dish.dietaryTags
    }
}

struct DailyCalorieEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    var foodItems: [FoodItem]
    var totalCalories: Int {
        return foodItems.reduce(0) { $0 + $1.calories }
    }
    var totalProtein: Int {
        return foodItems.reduce(0) { $0 + $1.protein }
    }
    var totalCarbs: Int {
        return foodItems.reduce(0) { $0 + $1.carbs }
    }
    var totalFat: Int {
        return foodItems.reduce(0) { $0 + $1.fat }
    }
    
    init(date: Date = Date(), foodItems: [FoodItem] = []) {
        self.date = date
        self.foodItems = foodItems
    }
}

struct UserSettings: Codable {
    var dailyCalorieGoal: Int = 2000
    var language: String = "English" // "English" or "Polish"
    var preferredUnits: String = "metric" // "metric" or "imperial"
    
    static let shared = UserSettings()
}

// MARK: - Progress Models
struct WeightEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    
    init(date: Date = Date(), weight: Double) {
        self.date = date
        self.weight = weight
    }
}

struct ProgressStats: Codable {
    var weeklyAverageCalories: Double = 0
    var monthlyAverageCalories: Double = 0
    var weeklyWeightChange: Double = 0
    var monthlyWeightChange: Double = 0
    var streakDays: Int = 0
}

// MARK: - AI Response Models
struct AIResponse: Codable {
    let candidates: [Candidate]
}

struct Candidate: Codable {
    let content: Content
}

struct Content: Codable {
    let parts: [Part]
}

struct Part: Codable {
    let text: String
}