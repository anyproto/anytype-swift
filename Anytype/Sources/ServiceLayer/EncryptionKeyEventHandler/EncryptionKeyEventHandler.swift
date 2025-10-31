import Services
import AnytypeCore
import NotificationsCore
import Foundation
import CryptoKit

protocol EncryptionKeyEventHandlerProtocol: AnyObject, Sendable {
    func startSubscription() async
}

actor EncryptionKeyEventHandler: EncryptionKeyEventHandlerProtocol {
    
    private let encryptionKeyService: any EncryptionKeyServiceProtocol = Container.shared.encryptionKeyService()
    
    @Injected(\.spaceViewsStorage)
    private var workspaceStorage: any SpaceViewsStorageProtocol
    
    func startSubscription() async {
        let stream = workspaceStorage.allSpaceViewsPublisher.values
            .map { $0.map { $0.pushNotificationEncryptionKey }.filter { $0.isNotEmpty } }
            .removeDuplicates()
        for await keys in stream {
            for key in keys {
                updateKey(key)
            }
        }
    }
    
    private func updateKey(_ key: String) {
        do {
            guard let keyData = Data(base64Encoded: key) else {
                throw CommonError.undefined
            }
            let keyId = SHA256.hash(data: keyData)
                    .compactMap { String(format: "%02x", $0) }
                    .joined()
            try encryptionKeyService.saveKey(key, keyId: keyId)
        } catch {
            anytypeAssertionFailure("Can't save encryption key", info: [
                "error": error.localizedDescription
            ])
        }
    }
}
