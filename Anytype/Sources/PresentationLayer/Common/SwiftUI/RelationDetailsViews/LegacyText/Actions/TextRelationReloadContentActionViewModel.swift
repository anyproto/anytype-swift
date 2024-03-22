import Foundation
import UIKit
import Services
import AnytypeCore


final class TextRelationReloadContentActionViewModel: TextRelationActionViewModelProtocol {
    
    private let objectDetails: ObjectDetails
    private let relationKey: String
    private let bookmarkService: BookmarkServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    
    let id = UUID().uuidString
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.X24.replace
    
    init?(
        objectDetails: ObjectDetails,
        relationKey: String,
        bookmarkService: BookmarkServiceProtocol,
        alertOpener: AlertOpenerProtocol
    ) {
        guard objectDetails.layoutValue == .bookmark,
              relationKey == BundledRelationKey.source.rawValue else { return nil }
        
        self.objectDetails = objectDetails
        self.relationKey = relationKey
        self.bookmarkService = bookmarkService
        self.alertOpener = alertOpener
    }
    
    var isActionAvailable: Bool {
        inputText.isValidURL()
    }
    
    func performAction() {
        Task { @MainActor in
            guard let url = AnytypeURL(string: inputText) else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            UISelectionFeedbackGenerator().selectionChanged()
            try await bookmarkService.fetchBookmarkContent(bookmarkId: objectDetails.id, url: url)
            alertOpener.showTopAlert(message: Loc.RelationAction.reloadingContent)
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.reloadSourceData)
        }
    }
}
