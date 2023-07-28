import Foundation
import UIKit
import Services

final class TextRelationReloadContentActionViewModel: TextRelationActionViewModelProtocol {
    
    private let objectDetails: ObjectDetails
    private let relation: Relation
    private let bookmarkService: BookmarkServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.X24.replace
    
    init?(
        objectDetails: ObjectDetails,
        relation: Relation,
        bookmarkService: BookmarkServiceProtocol,
        alertOpener: AlertOpenerProtocol
    ) {
        guard objectDetails.layoutValue == .bookmark,
              relation.isSource else { return nil }
        
        self.objectDetails = objectDetails
        self.relation = relation
        self.bookmarkService = bookmarkService
        self.alertOpener = alertOpener
    }
    
    var isActionAvailable: Bool {
        inputText.isValidURL()
    }
    
    func performAction() {
        Task { @MainActor in
            UISelectionFeedbackGenerator().selectionChanged()
            try await bookmarkService.fetchBookmarkContent(bookmarkId: objectDetails.id, url: inputText)
            alertOpener.showTopAlert(message: Loc.RelationAction.reloadingContent)
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.reloadSourceData)
        }
    }
}
