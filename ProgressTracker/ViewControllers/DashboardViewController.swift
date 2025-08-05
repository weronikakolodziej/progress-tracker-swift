import UIKit

class DashboardViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let dataManager = DataManager.shared
    
    // UI Components
    private let welcomeLabel = UILabel()
    private let dateLabel = UILabel()
    private let calorieProgressCard = UIView()
    private let calorieProgressLabel = UILabel()
    private let calorieProgressBar = UIProgressView()
    private let calorieCountLabel = UILabel()
    private let macroStackView = UIStackView()
    private let streakCard = UIView()
    private let streakLabel = UILabel()
    private let quickStatsCard = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Dashboard"
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Welcome section
        welcomeLabel.text = "Good morning!"
        welcomeLabel.font = .systemFont(ofSize: 28, weight: .bold)
        welcomeLabel.textColor = .label
        
        dateLabel.text = Date().formatted(style: .full)
        dateLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        
        // Calorie progress card
        setupCalorieProgressCard()
        
        // Streak card
        setupStreakCard()
        
        // Quick stats card
        setupQuickStatsCard()
        
        // Add all views to content view
        [welcomeLabel, dateLabel, calorieProgressCard, streakCard, quickStatsCard].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupCalorieProgressCard() {
        calorieProgressCard.backgroundColor = .cardBackground
        calorieProgressCard.roundCorners(radius: 16)
        calorieProgressCard.addShadow()
        
        calorieProgressLabel.text = "Today's Calories"
        calorieProgressLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        calorieProgressLabel.textColor = .label
        
        calorieCountLabel.text = "0 / 2000 kcal"
        calorieCountLabel.font = .systemFont(ofSize: 24, weight: .bold)
        calorieCountLabel.textColor = .primaryBlue
        
        calorieProgressBar.progressTintColor = .primaryBlue
        calorieProgressBar.trackTintColor = .systemGray5
        calorieProgressBar.layer.cornerRadius = 4
        calorieProgressBar.clipsToBounds = true
        
        // Macro breakdown
        macroStackView.axis = .horizontal
        macroStackView.distribution = .fillEqually
        macroStackView.spacing = 16
        
        let proteinView = createMacroView(title: "Protein", value: "0g", color: .primaryRed)
        let carbsView = createMacroView(title: "Carbs", value: "0g", color: .primaryOrange)
        let fatView = createMacroView(title: "Fat", value: "0g", color: .primaryGreen)
        
        macroStackView.addArrangedSubview(proteinView)
        macroStackView.addArrangedSubview(carbsView)
        macroStackView.addArrangedSubview(fatView)
        
        [calorieProgressLabel, calorieCountLabel, calorieProgressBar, macroStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            calorieProgressCard.addSubview($0)
        }
    }
    
    private func createMacroView(title: String, value: String, color: UIColor) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel(text: title, font: .systemFont(ofSize: 14, weight: .medium), textColor: .secondaryLabel)
        let valueLabel = UILabel(text: value, font: .systemFont(ofSize: 18, weight: .bold), textColor: color)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel], axis: .vertical, spacing: 4, alignment: .center)
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
        
        return containerView
    }
    
    private func setupStreakCard() {
        streakCard.backgroundColor = .cardBackground
        streakCard.roundCorners(radius: 16)
        streakCard.addShadow()
        
        let titleLabel = UILabel(text: "Current Streak", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .label)
        streakLabel.text = "0 days"
        streakLabel.font = .systemFont(ofSize: 32, weight: .bold)
        streakLabel.textColor = .primaryGreen
        streakLabel.textAlignment = .center
        
        let subtitleLabel = UILabel(text: "Keep it up!", font: .systemFont(ofSize: 14, weight: .medium), textColor: .secondaryLabel)
        subtitleLabel.textAlignment = .center
        
        [titleLabel, streakLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            streakCard.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -20),
            
            streakLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            streakLabel.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 20),
            streakLabel.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: streakLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupQuickStatsCard() {
        quickStatsCard.backgroundColor = .cardBackground
        quickStatsCard.roundCorners(radius: 16)
        quickStatsCard.addShadow()
        
        let titleLabel = UILabel(text: "Quick Stats", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .label)
        
        let weeklyAvgLabel = UILabel(text: "Weekly Avg: 0 kcal", font: .systemFont(ofSize: 14, weight: .medium), textColor: .secondaryLabel)
        let monthlyAvgLabel = UILabel(text: "Monthly Avg: 0 kcal", font: .systemFont(ofSize: 14, weight: .medium), textColor: .secondaryLabel)
        
        [titleLabel, weeklyAvgLabel, monthlyAvgLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            quickStatsCard.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: quickStatsCard.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: quickStatsCard.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: quickStatsCard.trailingAnchor, constant: -20),
            
            weeklyAvgLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            weeklyAvgLabel.leadingAnchor.constraint(equalTo: quickStatsCard.leadingAnchor, constant: 20),
            weeklyAvgLabel.trailingAnchor.constraint(equalTo: quickStatsCard.trailingAnchor, constant: -20),
            
            monthlyAvgLabel.topAnchor.constraint(equalTo: weeklyAvgLabel.bottomAnchor, constant: 8),
            monthlyAvgLabel.leadingAnchor.constraint(equalTo: quickStatsCard.leadingAnchor, constant: 20),
            monthlyAvgLabel.trailingAnchor.constraint(equalTo: quickStatsCard.trailingAnchor, constant: -20),
            monthlyAvgLabel.bottomAnchor.constraint(equalTo: quickStatsCard.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Welcome section
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Calorie progress card
            calorieProgressCard.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 24),
            calorieProgressCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calorieProgressCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            calorieProgressLabel.topAnchor.constraint(equalTo: calorieProgressCard.topAnchor, constant: 20),
            calorieProgressLabel.leadingAnchor.constraint(equalTo: calorieProgressCard.leadingAnchor, constant: 20),
            calorieProgressLabel.trailingAnchor.constraint(equalTo: calorieProgressCard.trailingAnchor, constant: -20),
            
            calorieCountLabel.topAnchor.constraint(equalTo: calorieProgressLabel.bottomAnchor, constant: 8),
            calorieCountLabel.leadingAnchor.constraint(equalTo: calorieProgressCard.leadingAnchor, constant: 20),
            calorieCountLabel.trailingAnchor.constraint(equalTo: calorieProgressCard.trailingAnchor, constant: -20),
            
            calorieProgressBar.topAnchor.constraint(equalTo: calorieCountLabel.bottomAnchor, constant: 12),
            calorieProgressBar.leadingAnchor.constraint(equalTo: calorieProgressCard.leadingAnchor, constant: 20),
            calorieProgressBar.trailingAnchor.constraint(equalTo: calorieProgressCard.trailingAnchor, constant: -20),
            calorieProgressBar.heightAnchor.constraint(equalToConstant: 8),
            
            macroStackView.topAnchor.constraint(equalTo: calorieProgressBar.bottomAnchor, constant: 20),
            macroStackView.leadingAnchor.constraint(equalTo: calorieProgressCard.leadingAnchor, constant: 20),
            macroStackView.trailingAnchor.constraint(equalTo: calorieProgressCard.trailingAnchor, constant: -20),
            macroStackView.bottomAnchor.constraint(equalTo: calorieProgressCard.bottomAnchor, constant: -20),
            macroStackView.heightAnchor.constraint(equalToConstant: 60),
            
            // Streak card
            streakCard.topAnchor.constraint(equalTo: calorieProgressCard.bottomAnchor, constant: 20),
            streakCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            streakCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Quick stats card
            quickStatsCard.topAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: 20),
            quickStatsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quickStatsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            quickStatsCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateData() {
        let todaysEntry = dataManager.getTodaysEntry()
        let goal = dataManager.userSettings.dailyCalorieGoal
        let progress = Float(todaysEntry.totalCalories) / Float(goal)
        
        // Update calorie progress
        calorieCountLabel.text = "\(todaysEntry.totalCalories) / \(goal) kcal"
        calorieProgressBar.setProgress(min(progress, 1.0), animated: true)
        
        // Update macros
        if let proteinView = macroStackView.arrangedSubviews[0] as? UIView,
           let proteinStack = proteinView.subviews.first as? UIStackView,
           let proteinLabel = proteinStack.arrangedSubviews[1] as? UILabel {
            proteinLabel.text = "\(todaysEntry.totalProtein)g"
        }
        
        if let carbsView = macroStackView.arrangedSubviews[1] as? UIView,
           let carbsStack = carbsView.subviews.first as? UIStackView,
           let carbsLabel = carbsStack.arrangedSubviews[1] as? UILabel {
            carbsLabel.text = "\(todaysEntry.totalCarbs)g"
        }
        
        if let fatView = macroStackView.arrangedSubviews[2] as? UIView,
           let fatStack = fatView.subviews.first as? UIStackView,
           let fatLabel = fatStack.arrangedSubviews[1] as? UILabel {
            fatLabel.text = "\(todaysEntry.totalFat)g"
        }
        
        // Update streak
        streakLabel.text = "\(dataManager.progressStats.streakDays) days"
        
        // Update quick stats
        if let weeklyLabel = quickStatsCard.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text?.contains("Weekly") == true }) {
            weeklyLabel.text = "Weekly Avg: \(Int(dataManager.progressStats.weeklyAverageCalories)) kcal"
        }
        
        if let monthlyLabel = quickStatsCard.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text?.contains("Monthly") == true }) {
            monthlyLabel.text = "Monthly Avg: \(Int(dataManager.progressStats.monthlyAverageCalories)) kcal"
        }
    }
}