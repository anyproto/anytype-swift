import Foundation
import Services
import Combine
import AnytypeCore

struct FavoriteBlockDetails: Equatable {
    let blockId: String
    let details: ObjectDetails
}

protocol FavoriteSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        homeDocument: some BaseDocumentProtocol,
        objectLimit: Int?,
        update: @escaping (_ details: [FavoriteBlockDetails]) -> Void
    )
    func stopSubscription()
}

final class FavoriteSubscriptionService: FavoriteSubscriptionServiceProtocol {
    
    private var subscriptions = [AnyCancellable]()
    
    func startSubscription(
        homeDocument: some BaseDocumentProtocol,
        objectLimit: Int?,
        update: @escaping (_ details: [FavoriteBlockDetails]) -> Void
    ) {
        
        guard subscriptions.isEmpty else {
            anytypeAssertionFailure("Favorite subscription already started")
            return
        }
        
        homeDocument.syncPublisher
            .map { [weak self, homeDocument] _ in self?.createChildren(document: homeDocument, objectLimit: objectLimit) ?? [] }
            .removeDuplicates()
            .receiveOnMain()
            .sink { result in
                update(result)
            }
            .store(in: &subscriptions)
    }
    
    func stopSubscription() {
        subscriptions.removeAll()
    }
    
    private func createChildren(document: some BaseDocumentProtocol, objectLimit: Int?) -> [FavoriteBlockDetails] {
        var details: [FavoriteBlockDetails] = []
        details.reserveCapacity(objectLimit ?? document.children.count)
        
        for info in document.children {
            
            if let objectLimit, details.count >= objectLimit {
                break
            }
            
            guard case .link(let link) = info.content else {
                // Home object contains title block. Ignore It.
                continue
            }
        
            guard let childDetails = document.detailsStorage.get(id: link.targetBlockID),
                  childDetails.isFavorite, childDetails.isNotDeletedAndSupportedForOpening else { continue }

            details.append(FavoriteBlockDetails(blockId: info.id, details: childDetails))
        }
        return details
    }
}
