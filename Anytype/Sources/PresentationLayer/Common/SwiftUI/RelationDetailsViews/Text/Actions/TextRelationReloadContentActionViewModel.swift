import Foundation
import UIKit
import BlocksModels

final class TextRelationReloadContentActionViewModel: TextRelationActionViewModelProtocol {
    
    private let objectId: BlockId
    private let relationValue: RelationValue
    private let bookmarkService: BookmarkServiceProtocol
    private let alertOpener: AlertOpenerProtocol
    
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.relationSmallReload
    
    init?(
        objectId: BlockId,
        relationValue: RelationValue,
        bookmarkService: BookmarkServiceProtocol,
        alertOpener: AlertOpenerProtocol
    ) {
        #warning("migrate to source constant")
        guard let objectInfo = ObjectDetailsStorage.shared.get(id: objectId),
              objectInfo.objectType.id == ObjectTypeId.bundled(.bookmark).rawValue,
              relationValue.key == "source" else { return nil }
        
        self.objectId = objectId
        self.relationValue = relationValue
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
