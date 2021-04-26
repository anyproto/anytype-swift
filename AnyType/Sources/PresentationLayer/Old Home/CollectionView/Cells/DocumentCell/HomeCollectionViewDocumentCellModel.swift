import UIKit
import Combine

class OldHomeCollectionViewDocumentCellModel: Hashable {
    internal init(page: DashboardPage, title: String, image: URL?, emoji: String?, subscriptions: Set<AnyCancellable> = []) {
        self.page = page
        self.title = title
        self.imageURL = image
        self.emoji = emoji
        self.subscriptions = subscriptions
    }
        
    // MARK: - Variables
    /// TODO: Remove published properties and use "plain" values instead.
    let page: DashboardPage
    @Published var title: String
    @Published var emoji: String?
    @Published var imageURL: URL?
    @Published var image: UIImage?
    var imagePublisher: AnyPublisher<UIImage?, Never> = .empty()
    var subscriptions: Set<AnyCancellable> = []
    var userActionSubject: PassthroughSubject<UserActionPayload, Never> = .init()

    // MARK: - Properties
    func imageExists() -> Bool {
        self.imageURL != nil
    }
    func emojiExists() -> Bool {
        self.emoji?.unicodeScalars.first?.properties.isEmoji == true
    }
    
    // MARK: - Providers
    func imageProvider() -> AnyPublisher<UIImage?, Never> {
        guard let imageURL = self.imageURL else {
            return Just(nil).eraseToAnyPublisher()
        }
        return ImageLoaderObject(imageURL).imagePublisher
    }
    
    // MARK: - Configuration
    func configured(titlePublisher: AnyPublisher<String?, Never>) {
        titlePublisher.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.title = value
        }.store(in: &self.subscriptions)
    }
    
    func configured(emojiImagePublisher: AnyPublisher<String?, Never>) {
        emojiImagePublisher.sink { [weak self] (value) in
            self?.emoji = value
        }.store(in: &self.subscriptions)
    }
    
    func configured(imagePublisher: AnyPublisher<String?, Never>) {
        self.imagePublisher = imagePublisher.safelyUnwrapOptionals()
            .flatMap({value in URLResolver.init().obtainImageURLPublisher(imageId: value).ignoreFailure()})
            .safelyUnwrapOptionals()
            .flatMap({value in ImageLoaderObject(value).imagePublisher})
            .eraseToAnyPublisher()
    }
    
    // MARK: - Hashable
    static func == (lhs: OldHomeCollectionViewDocumentCellModel, rhs: OldHomeCollectionViewDocumentCellModel) -> Bool {
        lhs.page.id == rhs.page.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.page.id)
    }
}

extension OldHomeCollectionViewDocumentCellModel {
    func configured(userActionSubject: PassthroughSubject<UserActionPayload, Never>) {
        self.userActionSubject = userActionSubject
    }
    
    struct UserActionPayload {
        typealias Model = String
        var model: Model
        var action: OldHomeCollectionViewDocumentCell.ContextualMenuHandler.UserAction
    }
}
