import Foundation
import UIKit
import BlocksModels

final class TextRelationReloadContentActionViewModel: TextRelationActionViewModelProtocol {
    
    private let objectId: BlockId
    private let relation: Relation
    private let bookmarkService: BookmarkServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.relationSmallReload
    
    init?(
        objectId: BlockId,
        relation: Relation,
        bookmarkService: BookmarkServiceProtocol,
        alertOpener: AlertOpenerProtocol
    ) {
        guard let objectInfo = ObjectDetailsStorage.shared.get(id: objectId),
              objectInfo.objectType.url == ObjectTypeUrl.bundled(.bookmark).rawValue,
              relation.isBundled else { return nil }
        
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
