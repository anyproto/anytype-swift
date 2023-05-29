import Foundation
import BlocksModels
import Combine
import AnytypeCore

struct FavoriteBlockDetails: Equatable {
    let blockId: String
    let details: ObjectDetails
}

protocol FavoriteSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        homeDocument: BaseDocumentProtocol,
        objectLimit: Int?,
        update: @escaping (_ details: [FavoriteBlockDetails]) -> Void
    )
    func stopSubscription()
}

final class FavoriteSubscriptionService: FavoriteSubscriptionServiceProtocol {
    
    private var subscriptions = [AnyCancellable]()
    private let objectDetailsStorage: ObjectDetailsStorage
    
    init(objectDetailsStorage: ObjectDetailsStorage) {
        self.objectDetailsStorage = objectDetailsStorage
    }
    
    func startSubscription(
        homeDocument: BaseDocumentProtocol,
        objectLimit: Int?,
        update: @escaping (_ details: [FavoriteBlockDetails]) -> Void
    ) {
        
        guard subscriptions.isEmpty else {
            anytypeAssertionFailure("Favorite subscription already started", domain: .subscriptionService)
            return
        }
        
        homeDocument.syncPublisher
            .map { [weak self, homeDocument] in self?.createChildren(children: homeDocument.children, objectLimit: objectLimit) ?? [] }
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
    
    private func createChildren(children: [BlockInformation], objectLimit: Int?) -> [FavoriteBlockDetails] {
        var details: [FavoriteBlockDetails] = []
        details.reserveCapacity(objectLimit ?? children.count)
        
        for info in children {
            
            if let objectLimit, details.count >= objectLimit {
                break
            }
            
            guard case .link(let link) = info.content else {
                anytypeAssertionFailure(
                    "Not link type in home screen dashboard: \(info.content)",
                    domain: .homeView
                )
                continue
            }
        
            guard let childDetails = objectDetailsStorage.get(id: link.targetBlockID),
                  childDetails.isFavorite, childDetails.isVisibleForEdit else { continue }

            details.append(FavoriteBlockDetails(blockId: info.id, details: childDetails))
        }
        return details
    }
}
