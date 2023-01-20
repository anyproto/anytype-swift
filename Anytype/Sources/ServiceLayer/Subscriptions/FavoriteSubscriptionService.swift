import Foundation
import BlocksModels
import Combine

protocol FavoriteSubscriptionServiceProtocol: AnyObject {
    func startSubscription(homeDocument: BaseDocumentProtocol, objectLimit: Int?, update: @escaping (_ details: [ObjectDetails], _ count: Int) -> Void)
    func stopSubscription()
}

final class FavoriteSubscriptionService: FavoriteSubscriptionServiceProtocol {
    
    private var subscriptions = [AnyCancellable]()
    private var objectDetailsStorage: ObjectDetailsStorage
    private var objectTypeProvider: ObjectTypeProviderProtocol
    
    init(objectDetailsStorage: ObjectDetailsStorage, objectTypeProvider: ObjectTypeProviderProtocol) {
        self.objectDetailsStorage = objectDetailsStorage
        self.objectTypeProvider = objectTypeProvider
    }
    
    func startSubscription(homeDocument: BaseDocumentProtocol, objectLimit: Int?, update: @escaping (_ details: [ObjectDetails], _ count: Int) -> Void) {
        
        // TODO: Discuss about publisher and maybe delete it
        if let links = homeDocument.details?.links {
            updateSubscription(links: links, objectLimit: objectLimit, update: update)
        }
        
        homeDocument.updatePublisher
            .compactMap { [homeDocument] _ in homeDocument.details?.links }
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] links in
                self?.updateSubscription(links: links, objectLimit: objectLimit, update: update)
            }
            .store(in: &subscriptions)
    }
    
    func stopSubscription() {
        subscriptions.removeAll()
    }
    
    private func updateSubscription(links: [String], objectLimit: Int?, update: @escaping (_ details: [ObjectDetails], _ count: Int) -> Void) {
        
        let details: [ObjectDetails] = links.compactMap {
            guard let details = objectDetailsStorage.get(id: $0),
                  objectTypeProvider.isSupportedForEdit(typeId: details.type) else { return nil }
            return details
        }
        
        let visibleDetails = objectLimit.map { Array(details.prefix($0)) } ?? details
        update(visibleDetails, details.count)
    }
}
