import Combine
import UIKit
import Services
import AnytypeCore

final class ObjectIconPickerViewModel: ObservableObject, ObjectIconPickerViewModelProtocol {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    @Published private(set) var isRemoveButtonAvailable: Bool = false
    @Published private(set) var detailsLayout: DetailsLayout?
    @Published private(set) var isRemoveEnabled: Bool = false

    // MARK: - Private variables
    
    private let document: BaseDocumentGeneralProtocol
    private let objectId: String
    private let fileService: FileActionsServiceProtocol
    private let detailsService: DetailsServiceProtocol
    
    private var subscription: AnyCancellable?
        
    // MARK: - Initializer
    
    init(
        document: BaseDocumentGeneralProtocol,
        objectId: String,
        fileService: FileActionsServiceProtocol,
        detailsService: DetailsServiceProtocol
    ) {
        self.document = document
        self.objectId = objectId
        self.fileService = fileService
        self.detailsService = detailsService
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
        case .basic:
            return true
        case .profile:
            guard let details = document.details else { return false }
            return details.iconImage.isNotNil
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
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
        Task {
            try await detailsService.updateBundledDetails([.iconEmoji(emojiUnicode), .iconImageHash(nil)])
        }
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
        let safeSendableItemProvider = SafeSendable(value: itemProvider)
        Task {
            let data = try await fileService.createFileData(source: .itemProvider(safeSendableItemProvider.value))
            let imageHash = try await fileService.uploadImage(data: data)
            try await detailsService.updateBundledDetails([.iconEmoji(""), .iconImageHash(imageHash)])
        }
    }
    
    func removeIcon() {
        // Analytics
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeIcon)
        Task {
            try await detailsService.updateBundledDetails(
                [.iconEmoji(""), .iconImageHash(nil)]
            )
        }
    }
    
}
