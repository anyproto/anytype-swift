
import UIKit

class BaseBlockMenuItemsViewController: UIViewController {
    
    private enum Constants {
        static let topBarHeight: CGFloat = 30
        static let backButtonTrailingPadding: CGFloat = 20
        static let labelLeadingPadding: CGFloat = 20
    }
    
    let customTopBar = UIView()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .captionFont
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let backButton = ButtonsFactory().makeBackButton { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }()
    
    private lazy var topBarHeightConstraint = self.customTopBar.heightAnchor.constraint(equalToConstant: Constants.topBarHeight)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.title
    }
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .systemBackground
        self.customTopBar.translatesAutoresizingMaskIntoConstraints = false
        self.customTopBar.addSubview(self.backButton)
        self.customTopBar.addSubview(self.titleLabel)
        self.view.addSubview(self.customTopBar)
        NSLayoutConstraint.activate([
            backButton.trailingAnchor.constraint(equalTo: self.customTopBar.trailingAnchor,
                                                 constant: -Constants.backButtonTrailingPadding),
            backButton.centerYAnchor.constraint(equalTo: self.customTopBar.centerYAnchor),
            self.topBarHeightConstraint,
            self.titleLabel.leadingAnchor.constraint(equalTo: self.customTopBar.leadingAnchor,
                                                       constant: Constants.labelLeadingPadding),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.customTopBar.centerYAnchor),
            self.view.topAnchor.constraint(equalTo: self.customTopBar.topAnchor),
            self.view.leadingAnchor.constraint(equalTo: self.customTopBar.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.customTopBar.trailingAnchor)
        ])
    }
    
    func setTopBarHidden(_ hidden: Bool) {
        self.topBarHeightConstraint.constant = hidden ? 0 : Constants.topBarHeight
    }
}
