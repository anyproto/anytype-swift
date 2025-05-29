import Services
import AnytypeCore
import NotificationsCore

protocol EncryptionKeyEventHandlerProtocol: AnyObject, Sendable {
    func startSubscription() async
}

final class EncryptionKeyEventHandler: EncryptionKeyEventHandlerProtocol {
    
    private let encryptionKeyService: any EncryptionKeyServiceProtocol = Container.shared.encryptionKeyService()
    
    func startSubscription() async {
        for await events in await EventBunchSubscribtion.default.stream() {
            for event in events.middlewareEvents {
                switch event.value {
                case let .pushEncryptionKeyUpdate(data):
                    updateKey(data.encryptionKey, keyId: data.encryptionKeyID)
                default:
                    break
                }
            }
        }
    }
    
    private func updateKey(_ key: String, keyId: String) {
        do {
            try encryptionKeyService.saveKey(key, keyId: keyId)
        } catch {
            anytypeAssertionFailure("Can't save encryption key", info: [
                "error": error.localizedDescription,
                "keyId": keyId
            ])
        }
    }
}
