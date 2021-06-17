
import Combine
import UIKit

/// Loading view controller with progress indicator
final class LoadingViewController: UIViewController {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let contentInsets: UIEdgeInsets = .init(top: 15, left: 20, bottom: 15, right: 20)
        static let itemSpacing: CGFloat = 20
        static let maxNumberOfLinesInInformationLabel = 3
        static let buttonTitleContentInsets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let informationText: String
    private var subscription: AnyCancellable?
    private let cancelHandler: () -> Void
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - progressPublisher: Publisher to update progress
    ///   - informationText: Text to display during displaying view controller
    ///   - cancelHandler: Handler for cancel button
    init(progressPublisher: AnyPublisher<Float, Error>,
         informationText: String,
         cancelHandler: @escaping () -> Void) {
        self.informationText = informationText
        self.cancelHandler = cancelHandler
        super.init(nibName: nil, bundle: nil)
        self.subscription = progressPublisher
            .receiveOnMain()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] progress in
                    self?.progressView.progress = progress
                  })
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView()
        self.view.backgroundColor = .clear
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = Constants.cornerRadius
        self.view.addSubview(container)
        NSLayoutConstraint.activate([
            self.view.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            self.view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            container.widthAnchor.constraint(equalTo: self.view.widthAnchor,
                                             constant: -Constants.contentInsets.left - Constants.contentInsets.right)
        ])
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.informationText
        label.textAlignment = .center
        label.font = .highlightFont
        label.numberOfLines = Constants.maxNumberOfLinesInInformationLabel
        
        let cancelButton = UIButton(primaryAction: UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: self.cancelHandler)
        }))
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Cancel",
                                                                                     comment: ""),
                                                           attributes: [.foregroundColor: UIColor.systemBackground,
                                                                        .font: UIFont.highlightFont]),
                                        for: .normal)
        cancelButton.contentEdgeInsets = Constants.buttonTitleContentInsets
        cancelButton.backgroundColor = .orange
        
        let stack = UIStackView(arrangedSubviews: [label, self.progressView, cancelButton])
        stack.spacing = Constants.itemSpacing
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(stack)
        stack.edgesToSuperview(insets: Constants.contentInsets)
    }
}

extension LoadingViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
