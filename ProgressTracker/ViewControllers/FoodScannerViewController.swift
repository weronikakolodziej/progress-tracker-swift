import UIKit
import AVFoundation

class FoodScannerViewController: UIViewController {
    
    private let dataManager = DataManager.shared
    private let aiService = AIService.shared
    
    // Camera components
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let cameraView = UIView()
    
    // UI Components
    private let titleLabel = UILabel()
    private let instructionLabel = UILabel()
    private let captureButton = UIButton()
    private let galleryButton = UIButton()
    private let loadingView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    
    // Results components
    private let resultsView = UIView()
    private let resultsTableView = UITableView()
    private let scanNewButton = UIButton()
    
    private var scannedDishes: [Dish] = []
    private var isShowingResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        checkCameraPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isShowingResults {
            startCamera()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Scan Menu"
        
        // Camera view setup
        cameraView.backgroundColor = .black
        cameraView.roundCorners(radius: 16)
        cameraView.clipsToBounds = true
        
        // Title and instruction
        titleLabel.text = "Scan Restaurant Menu"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        instructionLabel.text = "Point your camera at a menu to analyze dishes and get nutritional information"
        instructionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        instructionLabel.textColor = .secondaryLabel
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        
        // Buttons
        captureButton.setTitle("Capture Menu", for: .normal)
        captureButton.backgroundColor = .primaryBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        captureButton.roundCorners(radius: 12)
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        
        galleryButton.setTitle("Choose from Gallery", for: .normal)
        galleryButton.backgroundColor = .secondaryCardBackground
        galleryButton.setTitleColor(.label, for: .normal)
        galleryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        galleryButton.roundCorners(radius: 12)
        galleryButton.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        
        // Loading view
        setupLoadingView()
        
        // Results view
        setupResultsView()
        
        // Add views
        [cameraView, titleLabel, instructionLabel, captureButton, galleryButton, loadingView, resultsView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Initially hide loading and results
        loadingView.isHidden = true
        resultsView.isHidden = true
    }
    
    private func setupLoadingView() {
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        loadingView.roundCorners(radius: 16)
        
        loadingIndicator.color = .white
        loadingIndicator.startAnimating()
        
        loadingLabel.text = "Analyzing menu..."
        loadingLabel.font = .systemFont(ofSize: 18, weight: .medium)
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        
        [loadingIndicator, loadingLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            loadingView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 16),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 20),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupResultsView() {
        resultsView.backgroundColor = .systemBackground
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.register(DishTableViewCell.self, forCellReuseIdentifier: "DishCell")
        resultsTableView.backgroundColor = .systemBackground
        resultsTableView.separatorStyle = .none
        resultsTableView.showsVerticalScrollIndicator = false
        
        scanNewButton.setTitle("Scan New Menu", for: .normal)
        scanNewButton.backgroundColor = .primaryBlue
        scanNewButton.setTitleColor(.white, for: .normal)
        scanNewButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        scanNewButton.roundCorners(radius: 12)
        scanNewButton.addTarget(self, action: #selector(scanNewButtonTapped), for: .touchUpInside)
        
        [resultsTableView, scanNewButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            resultsView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            resultsTableView.topAnchor.constraint(equalTo: resultsView.topAnchor),
            resultsTableView.leadingAnchor.constraint(equalTo: resultsView.leadingAnchor),
            resultsTableView.trailingAnchor.constraint(equalTo: resultsView.trailingAnchor),
            resultsTableView.bottomAnchor.constraint(equalTo: scanNewButton.topAnchor, constant: -20),
            
            scanNewButton.leadingAnchor.constraint(equalTo: resultsView.leadingAnchor, constant: 20),
            scanNewButton.trailingAnchor.constraint(equalTo: resultsView.trailingAnchor, constant: -20),
            scanNewButton.bottomAnchor.constraint(equalTo: resultsView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            scanNewButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Instruction
            instructionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Camera view
            cameraView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 24),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cameraView.heightAnchor.constraint(equalTo: cameraView.widthAnchor, multiplier: 4.0/3.0),
            
            // Capture button
            captureButton.topAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: 24),
            captureButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            captureButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            captureButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Gallery button
            galleryButton.topAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: 12),
            galleryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            galleryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            galleryButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Loading view
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 200),
            loadingView.heightAnchor.constraint(equalToConstant: 120),
            
            // Results view
            resultsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Camera Setup
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
        default:
            showCameraPermissionAlert()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            showAlert(title: "Camera Error", message: "Unable to access camera")
            return
        }
        
        captureSession?.addInput(input)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = cameraView.bounds
        
        cameraView.layer.addSublayer(previewLayer!)
    }
    
    private func startCamera() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopCamera() {
        captureSession?.stopRunning()
    }
    
    private func showCameraPermissionAlert() {
        showAlert(title: "Camera Permission Required", 
                 message: "Please enable camera access in Settings to scan menus") {
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func captureButtonTapped() {
        // For demo purposes, we'll simulate capturing an image
        // In a real implementation, you would capture from the camera
        showLoadingView()
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.simulateMenuAnalysis()
        }
    }
    
    @objc private func galleryButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true)
    }
    
    @objc private func scanNewButtonTapped() {
        hideResultsView()
    }
    
    // MARK: - UI State Management
    private func showLoadingView() {
        loadingView.isHidden = false
        loadingView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 1
        }
    }
    
    private func hideLoadingView() {
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        } completion: { _ in
            self.loadingView.isHidden = true
        }
    }
    
    private func showResultsView() {
        isShowingResults = true
        stopCamera()
        
        resultsView.isHidden = false
        resultsView.alpha = 0
        resultsTableView.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.resultsView.alpha = 1
        }
    }
    
    private func hideResultsView() {
        isShowingResults = false
        scannedDishes = []
        
        UIView.animate(withDuration: 0.3) {
            self.resultsView.alpha = 0
        } completion: { _ in
            self.resultsView.isHidden = true
            self.startCamera()
        }
    }
    
    // MARK: - Menu Analysis
    private func analyzeMenu(image: UIImage) {
        showLoadingView()
        
        aiService.analyzeFoodMenu(image: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoadingView()
                
                switch result {
                case .success(let dishes):
                    self?.scannedDishes = dishes
                    self?.showResultsView()
                case .failure(let error):
                    self?.showAlert(title: "Analysis Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func simulateMenuAnalysis() {
        // Simulate successful analysis with sample data
        scannedDishes = [
            Dish(originalName: "Grilled Salmon", translatedName: "Grilled Salmon", calories: "350 kcal", protein: "35g", carbs: "5g", fat: "20g", dietaryTags: ["Keto"]),
            Dish(originalName: "Caesar Salad", translatedName: "Caesar Salad", calories: "280 kcal", protein: "12g", carbs: "15g", fat: "22g", dietaryTags: ["Vegetarian"]),
            Dish(originalName: "Margherita Pizza", translatedName: "Margherita Pizza", calories: "520 kcal", protein: "18g", carbs: "65g", fat: "20g", dietaryTags: ["Vegetarian"])
        ]
        
        hideLoadingView()
        showResultsView()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FoodScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            analyzeMenu(image: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FoodScannerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scannedDishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DishCell", for: indexPath) as! DishTableViewCell
        cell.configure(with: scannedDishes[indexPath.row])
        cell.onAddToTracker = { [weak self] dish in
            self?.addDishToTracker(dish)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func addDishToTracker(_ dish: Dish) {
        let foodItem = FoodItem(from: dish)
        dataManager.addFoodItem(foodItem)
        
        showAlert(title: "Added to Tracker", message: "\(dish.translatedName.isEmpty ? dish.originalName : dish.translatedName) has been added to your daily calorie tracker.")
    }
}

// MARK: - DishTableViewCell
class DishTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    private let dishNameLabel = UILabel()
    private let originalNameLabel = UILabel()
    private let caloriesLabel = UILabel()
    private let macrosLabel = UILabel()
    private let tagsStackView = UIStackView()
    private let addButton = UIButton()
    
    var onAddToTracker: ((Dish) -> Void)?
    private var dish: Dish?
    
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
        
        dishNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        dishNameLabel.textColor = .label
        dishNameLabel.numberOfLines = 0
        
        originalNameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        originalNameLabel.textColor = .secondaryLabel
        originalNameLabel.numberOfLines = 0
        
        caloriesLabel.font = .systemFont(ofSize: 16, weight: .bold)
        caloriesLabel.textColor = .primaryBlue
        
        macrosLabel.font = .systemFont(ofSize: 14, weight: .medium)
        macrosLabel.textColor = .secondaryLabel
        macrosLabel.numberOfLines = 0
        
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .leading
        
        addButton.setTitle("Add to Tracker", for: .normal)
        addButton.backgroundColor = .primaryGreen
        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        addButton.roundCorners(radius: 8)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(containerView)
        [dishNameLabel, originalNameLabel, caloriesLabel, macrosLabel, tagsStackView, addButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            dishNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dishNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dishNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            originalNameLabel.topAnchor.constraint(equalTo: dishNameLabel.bottomAnchor, constant: 4),
            originalNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            originalNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            caloriesLabel.topAnchor.constraint(equalTo: originalNameLabel.bottomAnchor, constant: 8),
            caloriesLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            macrosLabel.topAnchor.constraint(equalTo: caloriesLabel.bottomAnchor, constant: 4),
            macrosLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            macrosLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            tagsStackView.topAnchor.constraint(equalTo: macrosLabel.bottomAnchor, constant: 8),
            tagsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tagsStackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            
            addButton.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 12),
            addButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            addButton.widthAnchor.constraint(equalToConstant: 120),
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(with dish: Dish) {
        self.dish = dish
        
        dishNameLabel.text = dish.translatedName.isEmpty ? dish.originalName : dish.translatedName
        originalNameLabel.text = dish.translatedName.isEmpty ? "" : "Original: \(dish.originalName)"
        originalNameLabel.isHidden = dish.translatedName.isEmpty
        
        caloriesLabel.text = dish.calories
        macrosLabel.text = "P: \(dish.protein) • C: \(dish.carbs) • F: \(dish.fat)"
        
        // Clear existing tags
        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add dietary tags
        dish.dietaryTags.forEach { tag in
            let tagLabel = createTagLabel(text: tag)
            tagsStackView.addArrangedSubview(tagLabel)
        }
    }
    
    private func createTagLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .primaryBlue
        label.textAlignment = .center
        label.roundCorners(radius: 8)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 24),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        return label
    }
    
    @objc private func addButtonTapped() {
        guard let dish = dish else { return }
        onAddToTracker?(dish)
    }
}