import Combine
import UIKit
import Services
import AnytypeCore

final class ObjectIconPickerViewModel: ObservableObject, ObjectIconPickerViewModelProtocol {
    
    let mediaPickerContentType: MediaPickerContentType = .images

    var isRemoveButtonAvailable: Bool { document.details?.icon != nil }

    var detailsLayout: DetailsLayout {
        document.details?.layoutValue ?? .basic
    }
    
    var isRemoveEnabled: Bool {
        switch detailsLayout {
        case .basic:
            return true
        case .profile:
            guard let details = document.details else { return false }
            return details.iconImage.isNotNil
        default:
            anytypeAssertionFailure(
                "`ObjectIconPickerViewModel` unavailable", info: ["detailsLayout": "\(detailsLayout.rawValue)"]
            )
            return true
        }
    }

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
    }
}

extension ObjectIconPickerViewModel {
    func setEmoji(_ emojiUnicode: String) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
        detailsService.updateBundledDetails([.iconEmoji(emojiUnicode), .iconImageHash(nil)])
    }
    
    func uploadImage(from itemProvider: NSItemProvider) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.setIcon)
        Task {
            let data = try await fileService.createFileData(source: .itemProvider(itemProvider))
            let imageHash = try await fileService.uploadImage(data: data)
            try await detailsService.updateBundledDetails([.iconEmoji(""), .iconImageHash(imageHash)])
        }
    }
    
    func removeIcon() {
        // Analytics
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.removeIcon)
        
        detailsService.updateBundledDetails(
            [.iconEmoji(""), .iconImageHash(nil)]
        )
    }
    
}
