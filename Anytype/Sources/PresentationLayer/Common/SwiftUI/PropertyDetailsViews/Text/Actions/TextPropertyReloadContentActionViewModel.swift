import Foundation
import UIKit
import Services
import AnytypeCore


final class TextPropertyReloadContentActionViewModel: TextPropertyActionViewModelProtocol {
    
    @Injected(\.bookmarkService)
    private var bookmarkService: any BookmarkServiceProtocol
    
    private let objectDetails: ObjectDetails
    private let relationKey: String
    private weak var delegate: (any TextPropertyActionButtonViewModelDelegate)?
    
    let id = UUID().uuidString
    var inputText: String = ""
    let title: String = Loc.RelationAction.reloadContent
    let iconAsset = ImageAsset.X24.replace
    
    init?(
        objectDetails: ObjectDetails,
        relationKey: String,
        delegate: (any TextPropertyActionButtonViewModelDelegate)?
    ) {
        guard objectDetails.resolvedLayoutValue == .bookmark,
              relationKey == BundledPropertyKey.source.rawValue else { return nil }
        
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
