import UIKit
import Services
import AnytypeCore

struct ObjectIconPickerData: Identifiable {
    let document: any BaseDocumentProtocol
    var id: String { document.objectId }
}

enum ObjectIconPickerAction {
    enum IconSource {
        case emoji(emojiUnicode: String)
        case upload(itemProvider: NSItemProvider)
        case customIcon(data: CustomIconData)
    }

    case setIcon(IconSource)
    case removeIcon
}

@MainActor
@Observable
final class ObjectIconPickerViewModel {

    @ObservationIgnored @Injected(\.objectHeaderUploadingService)
    private var objectHeaderUploadingService: any ObjectHeaderUploadingServiceProtocol

    let mediaPickerContentType: MediaPickerContentType = .images

    private(set) var isRemoveButtonAvailable: Bool = false
    private(set) var detailsLayout: DetailsLayout?
    private(set) var isRemoveEnabled: Bool = false

    // MARK: - Private variables

    @ObservationIgnored
    private let document: any BaseDocumentProtocol

    // MARK: - Initializer

    init(data: ObjectIconPickerData) {
        self.document = data.document
    }

    func startSubscription() async {
        for await details in document.detailsPublisher.values {
            updateState(details: details)
        }
    }
    
    
    func setEmoji(_ emojiUnicode: String) {
        handleIconAction(document: document, action: .setIcon(.emoji(emojiUnicode: emojiUnicode)))
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        handleIconAction(document: document, action: .setIcon(.upload(itemProvider: itemProvider)))
    }
    
    func setIcon(_ icon: CustomIcon, color: CustomIconColor) {
        handleIconAction(document: document, action: .setIcon(.customIcon(data: CustomIconData(icon: icon, customColor: color))))
    }
    
    func removeIcon() {
        handleIconAction(document: document, action: .removeIcon)
    }
    
    // MARK: - Private
    
    private func updateState(details: ObjectDetails) {
        isRemoveButtonAvailable = details.objectIcon != nil
        detailsLayout = details.resolvedLayoutValue
        isRemoveEnabled = makeIsRemoveEnabled(details: details)
    }
    
    private func makeIsRemoveEnabled(details: ObjectDetails) -> Bool {
        switch detailsLayout {
        case .basic, .set, .collection, .objectType:
            return true
        case .profile, .participant, .space, .spaceView, .chatDerived:
            return details.iconImage.isNotEmpty
        default:
            anytypeAssertionFailure(
                "`ObjectIconPickerViewModel` unavailable",
                info: ["detailsLayout": String(detailsLayout?.rawValue ?? 0)]
            )
            return true
        }
    }
    
    private func handleIconAction(document: some BaseDocumentProtocol, action: ObjectIconPickerAction) {
        Task {
            try await objectHeaderUploadingService.handleIconAction(
                objectId: document.objectId,
                spaceId: document.spaceId,
                action: action
            )
        }
    }
}
