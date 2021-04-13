import SwiftUI
import Combine

final class HomeCollectionViewDocumentCell: UICollectionViewCell {
    static let reuseIdentifer = "homeCollectionViewDocumentCellReuseIdentifier"
    
    let developerOptionsService = ServiceLocator.shared.developerOptionsService()
    
    let titleLabel: UILabel = .init()
    let emoji: UILabel = .init()
    let imageView: UIImageView = .init()
    let roundView: UIView = .init()
    
    private var layout: Layout = .init()
    private var style: Style = .presentation
    private var contextualMenuHandler: ContextualMenuHandler = .init()
    
    private var storedPage: DashboardPage = .empty
    
    var titleSubscription: AnyCancellable?
    var emojiSubscription: AnyCancellable?
    var imageSubscription: AnyCancellable?
    var imageLoadingSubscription: AnyCancellable?
    var userActionSubscription: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func invalidateSubscriptions() {
        self.titleSubscription = nil
        self.emojiSubscription = nil
        self.imageSubscription = nil
        self.imageLoadingSubscription = nil
        self.userActionSubscription = nil
    }
    
    func invalidateData() {
        self.titleLabel.text = nil
        self.imageView.image = nil
        self.emoji.text = nil
    }
    
    func syncViews() {
        let imageExists = self.imageView.image != nil
        let emojiExists = self.emoji.text?.isEmpty == false
        self.emoji.isHidden = imageExists || !emojiExists
    }
    
    func updateWithModel(viewModel: HomeCollectionViewDocumentCellModel) {
        if viewModel.page != self.storedPage {
            self.invalidateSubscriptions()
            self.invalidateData()
        }
        self.storedPage = viewModel.page
        
        /// Subsrcibe on viewModel updates
        self.titleLabel.text = viewModel.title
        self.emoji.text = viewModel.emoji
        self.syncViews()
        self.titleSubscription = viewModel.$title.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.titleLabel.text = value
        }
        self.emojiSubscription = viewModel.$emoji.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.emoji.text = value
            self?.syncViews()
        }
        self.imageLoadingSubscription = viewModel.imagePublisher.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.imageView.image = value
            self?.syncViews()
        }
        self.userActionSubscription = self.contextualMenuHandler.userActionPublisher.sink{ [weak viewModel] (value) in
            if let id = viewModel?.page.id {
                viewModel?.userActionSubject.send(.init(model: id, action: value))
            }
        }
    }
}

extension HomeCollectionViewDocumentCell {
    struct Layout {
        let cornerRadius: CGFloat = 8.0
        let offset: CGFloat = 16.0
        let roundIconSize: CGSize = .init(width: 48, height: 48)
        var roundIconCornerRadius: CGFloat { self.roundIconSize.width / 2 }
    }
    
    enum Style {
        case presentation
        var backgroundColor: UIColor? {
            switch self {
            case .presentation: return .white
            }
        }
        var iconBackgroundColor: UIColor? {
            switch self {
            case .presentation: return UIColor(named: "TextEditor/Colors/Background")
            }
        }
    }
}

private extension HomeCollectionViewDocumentCell {
    func configureViews() {
        self.roundView.backgroundColor = self.style.iconBackgroundColor
        self.roundView.layer.cornerRadius = self.layout.roundIconCornerRadius
        
        self.roundView.clipsToBounds = true
        
        self.imageView.contentMode = .scaleAspectFit
        
        self.emoji.textAlignment = .center
    }
        
    func configureCell() {
        self.layer.cornerRadius = self.layout.cornerRadius
        self.backgroundColor = self.style.backgroundColor
        
        if developerOptionsService.current.workflow.dashboard.cellsHaveActionsOnLongTap {
            let interaction: UIContextMenuInteraction = .init(delegate: self.contextualMenuHandler)
            
            self.addInteraction(interaction)
        }
    }
    
    func configureLayout() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.roundView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.emoji.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.roundView)
        self.roundView.addSubview(self.imageView)
        self.roundView.addSubview(self.emoji)
        
        let offset = self.layout.offset
        let size = self.layout.roundIconSize
        
        if let superview = self.roundView.superview {
            let view = self.roundView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: offset),
                view.heightAnchor.constraint(equalToConstant: size.height),
                view.widthAnchor.constraint(equalToConstant: size.width)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.imageView.superview {
            let view = self.imageView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.emoji.superview {
            let view = self.emoji
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                view.topAnchor.constraint(equalTo: superview.topAnchor),
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.titleLabel.superview {
            let view = self.titleLabel
            let topView = self.imageView
            let constraints = [
                view.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: offset),
                view.leftAnchor.constraint(equalTo: topView.leftAnchor),
                view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -offset),
                view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    func configure() {
        self.configureCell()
        self.configureViews()
        self.configureLayout()
    }
}

