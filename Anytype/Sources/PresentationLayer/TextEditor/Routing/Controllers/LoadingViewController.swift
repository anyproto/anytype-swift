
import Combine
import UIKit

/// Loading view controller with progress indicator
final class LoadingViewController: UIViewController {
    
    private enum Constants {
        static let cornerRadius: CGFloat = 10
        static let contentInsets: UIEdgeInsets = .init(top: 15, left: 20, bottom: 15, right: 20)
        static let itemSpacing: CGFloat = 20
        static let maxNumberOfLinesInInformationLabel = 3
    }
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let informationText: String
    private var subscriptions = [AnyCancellable]()
    private let loadData: FileLoaderReturnValue
    private let loadingCompletion: (URL) -> ()
    
    init(
        loadData: FileLoaderReturnValue,
        informationText: String,
        loadingCompletion: @escaping (URL) -> ()
    ) {
        self.loadData = loadData
        self.informationText = informationText
        self.loadingCompletion = loadingCompletion
        super.init(nibName: nil, bundle: nil)
        
        setupSubscriptions(loadData: loadData)
        
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubscriptions(loadData: FileLoaderReturnValue) {
        loadData.progressPublisher
            .map { $0.percentComplete }
            .receiveOnMain()
            .sinkWithDefaultCompletion("Loading progress", domain: .loadingController) { [weak self] progress in
                self?.progressView.progress = progress
            }.store(in: &subscriptions)
        
        loadData.progressPublisher
            .map { $0.fileURL }
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .sinkWithDefaultCompletion("Load File", domain: .loadingController) { [weak self] url in
                self?.dismiss(animated: true) {
                    self?.loadingCompletion(url)
                }
            }
            .store(in: &subscriptions)

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
        label.font = .uxBodyRegular
        label.numberOfLines = Constants.maxNumberOfLinesInInformationLabel
        
        let cancelButton = UIButton(
            primaryAction: UIAction { [weak self] _ in
                guard let self = self else { return }
                
                self.dismiss(animated: true, completion: self.loadData.task.cancel)
            }
        )
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setAttributedTitle(
            NSAttributedString(
                string: NSLocalizedString("Cancel",comment: ""),
                attributes: [
                    .foregroundColor: UIColor.systemBackground,
                    .font: UIFont.uxBodyRegular
                ]
            ),
            for: .normal
        )
        
        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            cancelButton.configuration = configuration
        } else {
            cancelButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        
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
