import UIKit

// MARK: - UIColor Extensions
extension UIColor {
    static let primaryBlue = UIColor.systemBlue
    static let primaryGreen = UIColor.systemGreen
    static let primaryRed = UIColor.systemRed
    static let primaryOrange = UIColor.systemOrange
    
    static let cardBackground = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray6 : UIColor.white
    }
    
    static let secondaryCardBackground = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.systemGray6
    }
}

// MARK: - UIView Extensions
extension UIView {
    func addShadow(radius: CGFloat = 8, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 2)) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
    
    func roundCorners(radius: CGFloat = 12) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func addBorder(width: CGFloat = 1, color: UIColor = .systemGray4) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}

// MARK: - Date Extensions
extension Date {
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func isYesterday() -> Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    func daysBetween(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }
}

// MARK: - String Extensions
extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}

// MARK: - UIViewController Extensions
extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    func showActionSheet(title: String, message: String, actions: [UIAlertAction]) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        actions.forEach { actionSheet.addAction($0) }
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // For iPad support
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true)
    }
}

// MARK: - UIStackView Extensions
extension UIStackView {
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
    }
}

// MARK: - UILabel Extensions
extension UILabel {
    convenience init(text: String = "", font: UIFont = .systemFont(ofSize: 17), textColor: UIColor = .label, textAlignment: NSTextAlignment = .left, numberOfLines: Int = 1) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
    }
}

// MARK: - UIButton Extensions
extension UIButton {
    convenience init(title: String, titleColor: UIColor = .white, backgroundColor: UIColor = .systemBlue, cornerRadius: CGFloat = 8) {
        self.init(type: .system)
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = cornerRadius
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }
    
    func setLoading(_ loading: Bool) {
        if loading {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.color = titleColor(for: .normal)
            activityIndicator.startAnimating()
            activityIndicator.tag = 999
            
            setTitle("", for: .normal)
            addSubview(activityIndicator)
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            isEnabled = false
        } else {
            viewWithTag(999)?.removeFromSuperview()
            isEnabled = true
        }
    }
}