import UIKit

class ProgressViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // UI Components
    private let titleLabel = UILabel()
    private let statsCardsStackView = UIStackView()
    private let chartsContainer = UIView()
    private let weightChartView = UIView()
    private let calorieChartView = UIView()
    private let addWeightButton = UIButton()
    
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
        title = "Progress"
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Title
        titleLabel.text = "Your Progress"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        
        // Stats cards
        setupStatsCards()
        
        // Charts
        setupCharts()
        
        // Add weight button
        addWeightButton.setTitle("Add Weight Entry", for: .normal)
        addWeightButton.backgroundColor = .primaryGreen
        addWeightButton.setTitleColor(.white, for: .normal)
        addWeightButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addWeightButton.roundCorners(radius: 12)
        addWeightButton.addTarget(self, action: #selector(addWeightButtonTapped), for: .touchUpInside)
        
        // Add all views to content view
        [titleLabel, statsCardsStackView, chartsContainer, addWeightButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupStatsCards() {
        statsCardsStackView.axis = .vertical
        statsCardsStackView.spacing = 16
        statsCardsStackView.distribution = .fillEqually
        
        let weeklyStatsCard = createStatsCard(
            title: "Weekly Summary",
            stats: [
                ("Avg Calories", "0 kcal", .primaryBlue),
                ("Weight Change", "0 kg", .primaryGreen)
            ]
        )
        
        let monthlyStatsCard = createStatsCard(
            title: "Monthly Summary",
            stats: [
                ("Avg Calories", "0 kcal", .primaryBlue),
                ("Weight Change", "0 kg", .primaryGreen)
            ]
        )
        
        let streakCard = createStatsCard(
            title: "Current Streak",
            stats: [
                ("Days", "0", .primaryOrange)
            ]
        )
        
        statsCardsStackView.addArrangedSubview(weeklyStatsCard)
        statsCardsStackView.addArrangedSubview(monthlyStatsCard)
        statsCardsStackView.addArrangedSubview(streakCard)
    }
    
    private func createStatsCard(title: String, stats: [(String, String, UIColor)]) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .cardBackground
        cardView.roundCorners(radius: 16)
        cardView.addShadow()
        
        let titleLabel = UILabel(text: title, font: .systemFont(ofSize: 18, weight: .semibold), textColor: .label)
        
        let statsStackView = UIStackView()
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 16
        
        for (statTitle, statValue, color) in stats {
            let statView = createStatView(title: statTitle, value: statValue, color: color)
            statsStackView.addArrangedSubview(statView)
        }
        
        [titleLabel, statsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            statsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            statsStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            statsStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            statsStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            cardView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return cardView
    }
    
    private func createStatView(title: String, value: String, color: UIColor) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel(text: title, font: .systemFont(ofSize: 14, weight: .medium), textColor: .secondaryLabel, textAlignment: .center)
        let valueLabel = UILabel(text: value, font: .systemFont(ofSize: 20, weight: .bold), textColor: color, textAlignment: .center)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel], axis: .vertical, spacing: 4, alignment: .center)
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    private func setupCharts() {
        chartsContainer.backgroundColor = .clear
        
        // Weight chart
        weightChartView.backgroundColor = .cardBackground
        weightChartView.roundCorners(radius: 16)
        weightChartView.addShadow()
        
        let weightTitleLabel = UILabel(text: "Weight Progress", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .label)
        let weightChartPlaceholder = createChartPlaceholder(text: "Weight chart will appear here")
        
        [weightTitleLabel, weightChartPlaceholder].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            weightChartView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            weightTitleLabel.topAnchor.constraint(equalTo: weightChartView.topAnchor, constant: 20),
            weightTitleLabel.leadingAnchor.constraint(equalTo: weightChartView.leadingAnchor, constant: 20),
            weightTitleLabel.trailingAnchor.constraint(equalTo: weightChartView.trailingAnchor, constant: -20),
            
            weightChartPlaceholder.topAnchor.constraint(equalTo: weightTitleLabel.bottomAnchor, constant: 16),
            weightChartPlaceholder.leadingAnchor.constraint(equalTo: weightChartView.leadingAnchor, constant: 20),
            weightChartPlaceholder.trailingAnchor.constraint(equalTo: weightChartView.trailingAnchor, constant: -20),
            weightChartPlaceholder.bottomAnchor.constraint(equalTo: weightChartView.bottomAnchor, constant: -20)
        ])
        
        // Calorie chart
        calorieChartView.backgroundColor = .cardBackground
        calorieChartView.roundCorners(radius: 16)
        calorieChartView.addShadow()
        
        let calorieTitleLabel = UILabel(text: "Calorie History", font: .systemFont(ofSize: 18, weight: .semibold), textColor: .label)
        let calorieChartPlaceholder = createChartPlaceholder(text: "Calorie chart will appear here")
        
        [calorieTitleLabel, calorieChartPlaceholder].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            calorieChartView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            calorieTitleLabel.topAnchor.constraint(equalTo: calorieChartView.topAnchor, constant: 20),
            calorieTitleLabel.leadingAnchor.constraint(equalTo: calorieChartView.leadingAnchor, constant: 20),
            calorieTitleLabel.trailingAnchor.constraint(equalTo: calorieChartView.trailingAnchor, constant: -20),
            
            calorieChartPlaceholder.topAnchor.constraint(equalTo: calorieTitleLabel.bottomAnchor, constant: 16),
            calorieChartPlaceholder.leadingAnchor.constraint(equalTo: calorieChartView.leadingAnchor, constant: 20),
            calorieChartPlaceholder.trailingAnchor.constraint(equalTo: calorieChartView.trailingAnchor, constant: -20),
            calorieChartPlaceholder.bottomAnchor.constraint(equalTo: calorieChartView.bottomAnchor, constant: -20)
        ])
        
        let chartsStackView = UIStackView(arrangedSubviews: [weightChartView, calorieChartView], axis: .vertical, spacing: 20)
        
        chartsContainer.addSubview(chartsStackView)
        chartsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartsStackView.topAnchor.constraint(equalTo: chartsContainer.topAnchor),
            chartsStackView.leadingAnchor.constraint(equalTo: chartsContainer.leadingAnchor),
            chartsStackView.trailingAnchor.constraint(equalTo: chartsContainer.trailingAnchor),
            chartsStackView.bottomAnchor.constraint(equalTo: chartsContainer.bottomAnchor),
            
            weightChartView.heightAnchor.constraint(equalToConstant: 200),
            calorieChartView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func createChartPlaceholder(text: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .secondaryCardBackground
        containerView.roundCorners(radius: 8)
        
        let label = UILabel(text: text, font: .systemFont(ofSize: 16, weight: .medium), textColor: .secondaryLabel, textAlignment: .center)
        label.numberOfLines = 0
        
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        return containerView
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
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Stats cards
            statsCardsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            statsCardsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statsCardsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Charts
            chartsContainer.topAnchor.constraint(equalTo: statsCardsStackView.bottomAnchor, constant: 24),
            chartsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            chartsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Add weight button
            addWeightButton.topAnchor.constraint(equalTo: chartsContainer.bottomAnchor, constant: 24),
            addWeightButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            addWeightButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addWeightButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            addWeightButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func updateData() {
        let stats = dataManager.progressStats
        
        // Update weekly stats card
        if let weeklyCard = statsCardsStackView.arrangedSubviews[0] as? UIView,
           let weeklyStackView = weeklyCard.subviews.compactMap({ $0 as? UIStackView }).first {
            
            if let calorieView = weeklyStackView.arrangedSubviews[0] as? UIView,
               let calorieStack = calorieView.subviews.first as? UIStackView,
               let calorieLabel = calorieStack.arrangedSubviews[1] as? UILabel {
                calorieLabel.text = "\(Int(stats.weeklyAverageCalories)) kcal"
            }
            
            if let weightView = weeklyStackView.arrangedSubviews[1] as? UIView,
               let weightStack = weightView.subviews.first as? UIStackView,
               let weightLabel = weightStack.arrangedSubviews[1] as? UILabel {
                let change = stats.weeklyWeightChange
                let sign = change >= 0 ? "+" : ""
                weightLabel.text = "\(sign)\(String(format: "%.1f", change)) kg"
                weightLabel.textColor = change >= 0 ? .primaryRed : .primaryGreen
            }
        }
        
        // Update monthly stats card
        if let monthlyCard = statsCardsStackView.arrangedSubviews[1] as? UIView,
           let monthlyStackView = monthlyCard.subviews.compactMap({ $0 as? UIStackView }).first {
            
            if let calorieView = monthlyStackView.arrangedSubviews[0] as? UIView,
               let calorieStack = calorieView.subviews.first as? UIStackView,
               let calorieLabel = calorieStack.arrangedSubviews[1] as? UILabel {
                calorieLabel.text = "\(Int(stats.monthlyAverageCalories)) kcal"
            }
            
            if let weightView = monthlyStackView.arrangedSubviews[1] as? UIView,
               let weightStack = weightView.subviews.first as? UIStackView,
               let weightLabel = weightStack.arrangedSubviews[1] as? UILabel {
                let change = stats.monthlyWeightChange
                let sign = change >= 0 ? "+" : ""
                weightLabel.text = "\(sign)\(String(format: "%.1f", change)) kg"
                weightLabel.textColor = change >= 0 ? .primaryRed : .primaryGreen
            }
        }
        
        // Update streak card
        if let streakCard = statsCardsStackView.arrangedSubviews[2] as? UIView,
           let streakStackView = streakCard.subviews.compactMap({ $0 as? UIStackView }).first,
           let streakView = streakStackView.arrangedSubviews[0] as? UIView,
           let streakStack = streakView.subviews.first as? UIStackView,
           let streakLabel = streakStack.arrangedSubviews[1] as? UILabel {
            streakLabel.text = "\(stats.streakDays)"
        }
    }
    
    @objc private func addWeightButtonTapped() {
        let alert = UIAlertController(title: "Add Weight Entry", message: "Enter your current weight", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Weight (kg)"
            textField.keyboardType = .decimalPad
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let weightText = alert.textFields?[0].text,
                  let weight = Double(weightText), weight > 0 else {
                self.showAlert(title: "Invalid Input", message: "Please enter a valid weight")
                return
            }
            
            self.dataManager.addWeightEntry(weight)
            self.updateData()
            self.showAlert(title: "Weight Added", message: "Your weight entry has been saved")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}