import Combine
import UIKit

final class DocumentIconViewModel: PageBlockViewModel {
    
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var toViewEmoji: String = ""
    @Published var toViewImage: UIImage?
    @Published var fromUserActionSubject: PassthroughSubject<String, Never> = .init()
    
    var toModelEmojiSubject: PassthroughSubject<String, Never> = .init()
    
    fileprivate var actionMenuItems: [ActionMenuItem] = []
    
    // MARK: - Initialization
    
    override init(_ block: BlockModel) {
        super.init(block)
        self.setup(block: block)
        
        _ = self.configured(.init(shouldAddContextualMenu: false))
    }
    
    // MARK: Subclassing / Events
    
    override func onIncoming(event: PageBlockViewEvents) {
        switch event {
        case .pageDetailsViewModelDidSet:
            
            let wholeDetailsPublisher = self.pageDetailsViewModel?.wholeDetailsPublisher
            
            wholeDetailsPublisher?
                .map { $0.iconEmoji }
                .sink { [weak self] value in
                    value.flatMap { self?.toViewEmoji = $0.value }
                }
                .store(in: &self.subscriptions)
            
            wholeDetailsPublisher?
                .map { $0.iconImage?.value }
                .safelyUnwrapOptionals()
                .flatMap { value in
                    URLResolver.init().obtainImageURLPublisher(imageId: value).ignoreFailure()
                }
                .safelyUnwrapOptionals()
                .flatMap { value in
                    ImageLoaderObject(value).imagePublisher
                }
                .reciveOnMain()
                .sink { [weak self] value in
                    self?.toViewImage = value
                }
                .store(in: &self.subscriptions)
            
            self.toModelEmojiSubject.notableError().flatMap { [weak self] value in
                self?.pageDetailsViewModel?.update(
                    details: .iconEmoji(.init(value: value))
                ) ?? .empty()
            }
            .sink(
                receiveCompletion: { value in
                    switch value {
                    case .finished: return
                    case let .failure(error):
                        assertionFailure("PageBlocksViews emoji setDetails error has occured.\n\(error)")
                    }
                },
                receiveValue: {}
            ).store(in: &self.subscriptions)
        }
    }
    
    // MARK: Subclassing / Views
    
    override func makeUIView() -> UIView {
        DocumentIconView().configured(with: self)
    }
    
    /// Convert to UIAction
    func actions() -> [UIAction] {
        self.actionMenuItems.map(self.action(with:))
    }

}

extension DocumentIconViewModel {
    
    enum UserAction: String, CaseIterable {
        case select = "Choose emoji"
        case random = "Pick emoji randomly"
        case upload = "Upload photo"
        case remove = "Remove"
    }

    struct ActionMenuItem {
        var action: UserAction
        var title: String
        var imageName: String
    }
    
}

// MARK: - ActionMenu Actions

private extension DocumentIconViewModel {
    
    func select() {
        let model = EmojiPicker.ViewModel()
        
        model.$selectedEmoji.safelyUnwrapOptionals().sink { [weak self] (emoji) in
            self?.fromUserActionSubject.send(emoji.unicode)
        }.store(in: &subscriptions)
        
        self.send(userAction: .specific(.page(.emoji(.shouldShowEmojiPicker(model)))))
    }
    
    func random() {
        let emoji = EmojiPicker.Manager().random()
        self.fromUserActionSubject.send(emoji.unicode)
    }
    
    func remove() {
        if !self.toViewImage.isNil {
            // remove photo
            // else?
            self.pageDetailsViewModel?.update(details: .iconImage(.init(value: "")))?.sink(receiveCompletion: { [weak self] (value) in
                switch value {
                case .finished: self?.toViewImage = nil
                case let .failure(error):
                    assertionFailure("PageBlocksViews emoji setDetails removeImage error has occured.\n \(error)")
                }
            }, receiveValue: {_ in }).store(in: &self.subscriptions)
        }
        else {
            let emoji = EmojiPicker.Manager.Emoji.empty()
            self.fromUserActionSubject.send(emoji.unicode)
        }
    }
    
    func upload() {
        let model: CommonViews.Pickers.Picker.ViewModel = .init(type: .images)
        self.configureListening(model)
        self.send(userAction: .specific(.file(.shouldShowImagePicker(.init(model: model)))))
    }

    func configureListening(_ pickerViewModel: CommonViews.Pickers.Picker.ViewModel) {
        pickerViewModel.$resultInformation.safelyUnwrapOptionals().notableError()
            .flatMap(
                {
                    BlockActionsServiceFile().uploadFile.action(
                        url: "", localPath: $0.filePath, type: .image, disableEncryption: false
                    )
                }
            )
            .flatMap({[weak self] value in
                self?.pageDetailsViewModel?.update(details: .iconImage(.init(value: value.hash))) ?? .empty()
            })
            .sink(receiveCompletion: { value in
                switch value {
                case .finished: break
                case let .failure(value):
                    assertionFailure("uploading image error \(value) on \(self)")
                }
            }) { _ in }
            .store(in: &self.subscriptions)
    }
    
}

// MARK: - Setup

private extension DocumentIconViewModel {
    
    func setup(block: BlockModel) {
        self.setupSubscribers()
        self.setupActionMenuItems()
    }
    
    func setupSubscribers() {
        //TODO: Better to listen wholeDetailsPublisher when details is updating
        self.fromUserActionSubject.sink { [weak self] (value) in
            self?.toModelEmojiSubject.send(value)
        }.store(in: &subscriptions)
    }
    
    func setupActionMenuItems() {
        actionMenuItems = [
            ActionMenuItem(
                action: .select,
                title: UserAction.select.rawValue,
                imageName: "Emoji/ContextMenu/choose"
            ),
            ActionMenuItem(
                action: .random,
                title: UserAction.random.rawValue,
                imageName: "Emoji/ContextMenu/random"
            ),
            ActionMenuItem(
                action: .upload,
                title: UserAction.upload.rawValue,
                imageName: "Emoji/ContextMenu/upload"
            ),
            ActionMenuItem(
                action: .remove,
                title: UserAction.remove.rawValue,
                imageName: "Emoji/ContextMenu/remove"
            )
        ]
    }
    
    func action(with item: ActionMenuItem) -> UIAction {
        UIAction(
            title: item.title,
            image: UIImage(named: item.imageName)
        ) { action in
            self.handle(action: item.action)
        }
    }
    
    // MARK: - ActionMenu handler
    
    func handle(action: UserAction) {
        switch action {
        case .select: self.select()
        case .random: self.random()
        case .remove: self.remove()
        case .upload: self.upload()
        }
    }
    
}
