import Foundation
import UIKit
import Services

final class TextRelationReloadContentActionViewModel: TextRelationActionViewModelProtocol {
    
    private let objectId: BlockId
    private let relation: Relation
    private let bookmarkService: BookmarkServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.X24.replace
    
    init?(
        objectId: BlockId,
        relation: Relation,
        bookmarkService: BookmarkServiceProtocol,
        alertOpener: AlertOpenerProtocol
    ) {
        guard let objectInfo = ObjectDetailsStorage.shared.get(id: objectId),
              objectInfo.objectType.id == ObjectTypeId.bundled(.bookmark).rawValue,
              relation.isSource else { return nil }
        
        self.objectId = objectId
        self.relation = relation
        self.bookmarkService = bookmarkService
        self.alertOpener = alertOpener
    }
    
    var isActionAvailable: Bool {
        inputText.isValidURL()
    }
    
    func performAction() {
        UISelectionFeedbackGenerator().selectionChanged()
        bookmarkService.fetchBookmarkContent(bookmarkId: objectId, url: inputText)
        alertOpener.showTopAlert(message: Loc.RelationAction.reloadingContent)
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.reloadSourceData)
    }
}
