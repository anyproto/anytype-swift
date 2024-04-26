import Combine
import UIKit
import Services
import AnytypeCore

enum ObjectIconPickerAction {
    enum IconSource {
        case emoji(emojiUnicode: String)
        case upload(itemProvider: NSItemProvider)
    }
    
    case setIcon(IconSource)
    case removeIcon
}

final class ObjectIconPickerViewModel: ObservableObject, ObjectIconPickerViewModelProtocol {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    @Published private(set) var isRemoveButtonAvailable: Bool = false
    @Published private(set) var detailsLayout: DetailsLayout?
    @Published private(set) var isRemoveEnabled: Bool = false

    // MARK: - Private variables
    
    private let document: BaseDocumentGeneralProtocol
    private var subscription: AnyCancellable?
    private let onIconAction: (ObjectIconPickerAction) -> Void
        
    // MARK: - Initializer
    
    init(
        document: BaseDocumentGeneralProtocol,
        onIconAction: @escaping (ObjectIconPickerAction) -> Void
    ) {
        self.document = document
        self.onIconAction = onIconAction
        subscription = document.syncPublisher.sink { [weak self] in
            self?.updateState()
        }
    }
    
    private func updateState() {
        isRemoveButtonAvailable = document.details?.icon != nil
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
}

extension ObjectIconPickerViewModel {
    func setEmoji(_ emojiUnicode: String) {
        onIconAction(.setIcon(.emoji(emojiUnicode: emojiUnicode)))
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        onIconAction(.setIcon(.upload(itemProvider: itemProvider)))
    }
    
    func removeIcon() {
        onIconAction(.removeIcon)
    }
}
