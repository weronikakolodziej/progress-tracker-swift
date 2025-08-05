import UIKit

class CalorieTrackerViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private let tableView = UITableView()
    private let headerView = UIView()
    private let goalLabel = UILabel()
    private let progressView = UIProgressView()
    private let addButton = UIButton()
    private let settingsButton = UIButton()
    
    private var todaysEntry: DailyCalorieEntry {
        return dataManager.getTodaysEntry()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Calorie Tracker"
        
        // Navigation bar setup
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        
        // Header view setup
        setupHeaderView()
        
        // Table view setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FoodItemTableViewCell.self, forCellReuseIdentifier: "FoodItemCell")
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView
        
        // Add button
        addButton.setTitle("Add Food Item", for: .normal)
        addButton.backgroundColor = .primaryBlue
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.roundCorners(radius: 12)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        [tableView, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel(text: "Today's Progress", font: .systemFont(ofSize: 24, weight: .bold), textColor: .label)
        
        goalLabel.font = .systemFont(ofSize: 18, weight: .medium)
        goalLabel.textColor = .label
        goalLabel.textAlignment = .center
        
        progressView.progressTintColor = .primaryBlue
        progressView.trackTintColor = .systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        let macroContainer = createMacroContainer()
        
        [titleLabel, goalLabel, progressView, macroContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            goalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            goalLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            goalLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            progressView.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 12),
            progressView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            macroContainer.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            macroContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            macroContainer.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            macroContainer.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            macroContainer.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
    }
    
    private func createMacroContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .cardBackground
        container.roundCorners(radius: 12)
        container.addShadow(radius: 4, opacity: 0.1)
        
        let proteinView = createMacroView(title: "Protein", value: "0g", color: .primaryRed)
        let carbsView = createMacroView(title: "Carbs", value: "0g", color: .primaryOrange)
        let fatView = createMacroView(title: "Fat", value: "0g", color: .primaryGreen)
        
        let stackView = UIStackView(arrangedSubviews: [proteinView, carbsView, fatView], axis: .horizontal, distribution: .fillEqually)
        
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createMacroView(title: String, value: String, color: UIColor) -> UIView {
        let containerView = UIView()
        
        let titleLabel = UILabel(text: title, font: .systemFont(ofSize: 14, weight: .medium), textColor: .secondaryLabel, textAlignment: .center)
        let valueLabel = UILabel(text: value, font: .systemFont(ofSize: 18, weight: .bold), textColor: color, textAlignment: .center)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel], axis: .vertical, spacing: 4, alignment: .center)
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
        return containerView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -16),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func updateUI() {
        let entry = todaysEntry
        let goal = dataManager.userSettings.dailyCalorieGoal
        let progress = Float(entry.totalCalories) / Float(goal)
        
        goalLabel.text = "\(entry.totalCalories) / \(goal) kcal"
        progressView.setProgress(min(progress, 1.0), animated: true)
        
        // Update macros in header
        if let macroContainer = headerView.subviews.first(where: { $0.backgroundColor == .cardBackground }),
           let stackView = macroContainer.subviews.first as? UIStackView {
            
            if let proteinView = stackView.arrangedSubviews[0] as? UIView,
               let proteinStack = proteinView.subviews.first as? UIStackView,
               let proteinLabel = proteinStack.arrangedSubviews[1] as? UILabel {
                proteinLabel.text = "\(entry.totalProtein)g"
            }
            
            if let carbsView = stackView.arrangedSubviews[1] as? UIView,
               let carbsStack = carbsView.subviews.first as? UIStackView,
               let carbsLabel = carbsStack.arrangedSubviews[1] as? UILabel {
                carbsLabel.text = "\(entry.totalCarbs)g"
            }
            
            if let fatView = stackView.arrangedSubviews[2] as? UIView,
               let fatStack = fatView.subviews.first as? UIStackView,
               let fatLabel = fatStack.arrangedSubviews[1] as? UILabel {
                fatLabel.text = "\(entry.totalFat)g"
            }
        }
    }
    
    @objc private func addButtonTapped() {
        showAddFoodOptions()
    }
    
    @objc private func settingsButtonTapped() {
        showCalorieGoalSettings()
    }
    
    private func showAddFoodOptions() {
        let actions = [
            UIAlertAction(title: "Add New Food Item", style: .default) { _ in
                self.showAddNewFoodItem()
            },
            UIAlertAction(title: "Choose from Saved Items", style: .default) { _ in
                self.showSavedFoodItems()
            }
        ]
        
        showActionSheet(title: "Add Food Item", message: "Choose how you'd like to add a food item", actions: actions)
    }
    
    private func showAddNewFoodItem() {
        let alert = UIAlertController(title: "Add New Food Item", message: "Enter the details for your food item", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Food name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Calories"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "Protein (g)"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "Carbs (g)"
            textField.keyboardType = .numberPad
        }
        alert.addTextField { textField in
            textField.placeholder = "Fat (g)"
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let caloriesText = alert.textFields?[1].text, let calories = Int(caloriesText),
                  let proteinText = alert.textFields?[2].text, let protein = Int(proteinText),
                  let carbsText = alert.textFields?[3].text, let carbs = Int(carbsText),
                  let fatText = alert.textFields?[4].text, let fat = Int(fatText) else {
                self.showAlert(title: "Invalid Input", message: "Please fill in all fields with valid numbers")
                return
            }
            
            let foodItem = FoodItem(name: name, calories: calories, protein: protein, carbs: carbs, fat: fat)
            self.dataManager.addFoodItem(foodItem)
            self.updateUI()
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showSavedFoodItems() {
        let savedItemsVC = SavedFoodItemsViewController()
        savedItemsVC.onItemSelected = { [weak self] foodItem in
            self?.dataManager.addFoodItem(foodItem)
            self?.updateUI()
            self?.tableView.reloadData()
        }
        
        let navController = UINavigationController(rootViewController: savedItemsVC)
        present(navController, animated: true)
    }
    
    private func showCalorieGoalSettings() {
        let alert = UIAlertController(title: "Daily Calorie Goal", message: "Set your daily calorie target", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Daily calorie goal"
            textField.keyboardType = .numberPad
            textField.text = "\(self.dataManager.userSettings.dailyCalorieGoal)"
        }
        
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let goalText = alert.textFields?[0].text, let goal = Int(goalText), goal > 0 else {
                self.showAlert(title: "Invalid Input", message: "Please enter a valid calorie goal")
                return
            }
            
            self.dataManager.updateDailyCalorieGoal(goal)
            self.updateUI()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension CalorieTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todaysEntry.foodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell", for: indexPath) as! FoodItemTableViewCell
        cell.configure(with: todaysEntry.foodItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let foodItem = todaysEntry.foodItems[indexPath.row]
            dataManager.removeFoodItem(foodItem)
            updateUI()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - FoodItemTableViewCell
class FoodItemTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    private let caloriesLabel = UILabel()
    private let macrosLabel = UILabel()
    private let tagsStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = .cardBackground
        containerView.roundCorners(radius: 12)
        containerView.addShadow(radius: 4, opacity: 0.1)
        
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 0
        
        caloriesLabel.font = .systemFont(ofSize: 14, weight: .bold)
        caloriesLabel.textColor = .primaryBlue
        
        macrosLabel.font = .systemFont(ofSize: 12, weight: .medium)
        macrosLabel.textColor = .secondaryLabel
        
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 6
        tagsStackView.alignment = .leading
        
        contentView.addSubview(containerView)
        [nameLabel, caloriesLabel, macrosLabel, tagsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: caloriesLabel.leadingAnchor, constant: -8),
            
            caloriesLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            caloriesLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            caloriesLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            macrosLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            macrosLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            macrosLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            tagsStackView.topAnchor.constraint(equalTo: macrosLabel.bottomAnchor, constant: 8),
            tagsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -12),
            tagsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with foodItem: FoodItem) {
        nameLabel.text = foodItem.name
        caloriesLabel.text = "\(foodItem.calories) kcal"
        macrosLabel.text = "P: \(foodItem.protein)g • C: \(foodItem.carbs)g • F: \(foodItem.fat)g"
        
        // Clear existing tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add dietary tags
        foodItem.dietaryTags.forEach { tag in
            let tagLabel = createTagLabel(text: tag)
            tagsStackView.addArrangedSubview(tagLabel)
        }
    }
    
    private func createTagLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .primaryBlue
        label.textAlignment = .center
        label.roundCorners(radius: 6)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 20),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        return label
    }
}

// MARK: - SavedFoodItemsViewController
class SavedFoodItemsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let dataManager = DataManager.shared
    
    var onItemSelected: ((FoodItem) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Saved Food Items"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FoodItemTableViewCell.self, forCellReuseIdentifier: "FoodItemCell")
        tableView.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}

extension SavedFoodItemsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.savedFoodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell", for: indexPath) as! FoodItemTableViewCell
        cell.configure(with: dataManager.savedFoodItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = dataManager.savedFoodItems[indexPath.row]
        onItemSelected?(selectedItem)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}