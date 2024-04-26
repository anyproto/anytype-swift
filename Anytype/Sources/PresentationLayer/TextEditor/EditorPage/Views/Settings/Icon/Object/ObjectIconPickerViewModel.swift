import Combine
import UIKit
import Services
import AnytypeCore

struct ObjectIconPickerData: Identifiable {
    let document: BaseDocumentGeneralProtocol
    var id: String { document.objectId }
}

enum ObjectIconPickerAction {
    enum IconSource {
        case emoji(emojiUnicode: String)
        case upload(itemProvider: NSItemProvider)
    }
    
    case setIcon(IconSource)
    case removeIcon
}

final class ObjectIconPickerViewModel: ObservableObject {
    
    @Injected(\.objectHeaderUploadingService)
    private var objectHeaderUploadingService: ObjectHeaderUploadingServiceProtocol
    
    let mediaPickerContentType: MediaPickerContentType = .images

    @Published private(set) var isRemoveButtonAvailable: Bool = false
    @Published private(set) var detailsLayout: DetailsLayout?
    @Published private(set) var isRemoveEnabled: Bool = false

    // MARK: - Private variables
    
    private let document: BaseDocumentGeneralProtocol
    private var subscription: AnyCancellable?
        
    // MARK: - Initializer
    
    init(data: ObjectIconPickerData) {
        self.document = data.document
        subscription = document.syncPublisher
            .receiveOnMain()
            .sink { [weak self] in
                self?.updateState()
            }
    }
    
    
    func setEmoji(_ emojiUnicode: String) {
        handleIconAction(document: document, action: .setIcon(.emoji(emojiUnicode: emojiUnicode)))
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        handleIconAction(document: document, action: .setIcon(.upload(itemProvider: itemProvider)))
    }
    
    func removeIcon() {
        handleIconAction(document: document, action: .removeIcon)
    }
    
    // MARK: - Private
    
    private func updateState() {
        isRemoveButtonAvailable = document.details?.objectIcon != nil
        detailsLayout = document.details?.layoutValue
        isRemoveEnabled = makeIsRemoveEnabled()
    }
    
    private func makeIsRemoveEnabled() -> Bool {
        switch detailsLayout {
        case .basic, .set, .collection:
            return true
        case .profile, .participant, .space, .spaceView:
            guard let details = document.details else { return false }
            return details.iconImage.isNotEmpty
        default:
            anytypeAssertionFailure(
                "`ObjectIconPickerViewModel` unavailable",
                info: ["detailsLayout": String(detailsLayout?.rawValue ?? 0)]
            )
            return true
        }
    }
    
    private func handleIconAction(document: BaseDocumentGeneralProtocol, action: ObjectIconPickerAction) {
        Task {
            try await objectHeaderUploadingService.handleIconAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: action
            )
        }
    }
}
