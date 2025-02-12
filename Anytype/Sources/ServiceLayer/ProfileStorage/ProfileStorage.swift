import Foundation
import Combine
import Services
import AnytypeCore

protocol ProfileStorageProtocol: AnyObject, Sendable {
    var profile: Profile { get }
    var profilePublisher: AnyPublisher<Profile, Never> { get }
    
    func startSubscription() async
    func stopSubscription() async
}

final class ProfileStorage: ProfileStorageProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: any SingleObjectSubscriptionServiceProtocol = Container.shared.singleObjectSubscriptionService()
    private let accountManager: any AccountManagerProtocol = Container.shared.accountManager()

    private let subId = "ProfileStorage-\(UUID().uuidString)"
    private let storage = AtomicPublishedStorage(Profile(id: "", name: "", icon: .object(.profile(.placeholder)), sharedSpacesLimit: nil))

    // MARK: - Public

    var profile: Profile { storage.value }
    var profilePublisher: AnyPublisher<Profile, Never> { storage.publisher.eraseToAnyPublisher() }
    
    init() {}
    
    func startSubscription() async {
        await subscriptionService.startSubscription(
            subId: subId,
            spaceId: accountManager.account.info.techSpaceId,
            objectId: accountManager.account.info.profileObjectID,
            additionalKeys: [.sharedSpacesLimit]
        ) { [weak self] details in
            self?.storage.value = Profile(
                id: details.id,
                name: details.name,
                icon: details.objectIconImage,
                sharedSpacesLimit: details.sharedSpacesLimit
            )
        }
    }
    
    func stopSubscription() async {
        await subscriptionService.stopSubscription(subId: subId)
    }
}
