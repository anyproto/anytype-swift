import Foundation
import BlocksModels
import Combine
import AnytypeCore

protocol FavoriteSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        homeDocument: BaseDocumentProtocol,
        objectLimit: Int?,
        update: @escaping (_ details: [ObjectDetails]) -> Void
    )
    func stopSubscription()
}

final class FavoriteSubscriptionService: FavoriteSubscriptionServiceProtocol {
    
    private var subscriptions = [AnyCancellable]()
    private let objectDetailsStorage: ObjectDetailsStorage
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(objectDetailsStorage: ObjectDetailsStorage, objectTypeProvider: ObjectTypeProviderProtocol) {
        self.objectDetailsStorage = objectDetailsStorage
        self.objectTypeProvider = objectTypeProvider
    }
    
    func startSubscription(
        homeDocument: BaseDocumentProtocol,
        objectLimit: Int?,
        update: @escaping (_ details: [ObjectDetails]) -> Void
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
    
    private func createChildren(children: [BlockInformation], objectLimit: Int?) -> [ObjectDetails] {
        var details: [ObjectDetails] = []
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
                  childDetails.isFavorite, !childDetails.isArchived, !childDetails.isDeleted,
                  objectTypeProvider.isSupportedForEdit(typeId: childDetails.type) else { continue }

            details.append(childDetails)
        }
        return details
    }
}
