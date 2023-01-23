import Foundation
import BlocksModels
import Combine
import AnytypeCore

protocol FavoriteSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        homeDocument: BaseDocumentProtocol,
        objectLimit: Int?,
        update: @escaping (_ details: [ObjectDetails], _ count: Int) -> Void
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
        update: @escaping (_ details: [ObjectDetails], _ count: Int) -> Void
    ) {
        
        guard subscriptions.isEmpty else {
            anytypeAssertionFailure("Favorite subscription already started", domain: .subscriptionService)
            return
        }
        
        // TODO: Discuss about publisher and maybe delete it
        updateSubscription(children: homeDocument.children, objectLimit: objectLimit, update: update)
        
        homeDocument.updatePublisher
            .receiveOnMain()
            .sink { [weak self, homeDocument] links in
                self?.updateSubscription(children: homeDocument.children, objectLimit: objectLimit, update: update)
            }
            .store(in: &subscriptions)
    }
    
    func stopSubscription() {
        subscriptions.removeAll()
    }
    
    private func updateSubscription(children: [BlockInformation], objectLimit: Int?, update: @escaping (_ details: [ObjectDetails], _ count: Int) -> Void) {
        
        let details: [ObjectDetails] = children.compactMap { info in
            
            guard case .link(let link) = info.content else {
                anytypeAssertionFailure(
                    "Not link type in home screen dashboard: \(info.content)",
                    domain: .homeView
                )
                return nil
            }
        
            guard let details = objectDetailsStorage.get(id: link.targetBlockID),
                  details.isFavorite, !details.isArchived, !details.isDeleted,
                  objectTypeProvider.isSupportedForEdit(typeId: details.type) else { return nil }
            return details
        }
        
        let visibleDetails = objectLimit.map { Array(details.prefix($0)) } ?? details
        update(visibleDetails, details.count)
    }
}
