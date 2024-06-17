import Foundation
import UIKit
import Services
import AnytypeCore


final class TextRelationReloadContentActionViewModel: TextRelationActionViewModelProtocol {
    
    @Injected(\.bookmarkService)
    private var bookmarkService: BookmarkServiceProtocol
    
    private let objectDetails: ObjectDetails
    private let relationKey: String
    private weak var delegate: TextRelationActionButtonViewModelDelegate?
    
    let id = UUID().uuidString
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.X24.replace
    
    init?(
        objectDetails: ObjectDetails,
        relationKey: String,
        delegate: TextRelationActionButtonViewModelDelegate?
    ) {
        guard objectDetails.layoutValue == .bookmark,
              relationKey == BundledRelationKey.source.rawValue else { return nil }
        
        self.objectDetails = objectDetails
        self.relationKey = relationKey
        self.bookmarkService = bookmarkService
        self.delegate = delegate
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
            delegate?.showActionSuccessMessage(Loc.RelationAction.reloadingContent)
            AnytypeAnalytics.instance().logReloadSourceData()
        }
    }
}
