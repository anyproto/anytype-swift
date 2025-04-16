import Services
import AnytypeCore

protocol EncryptionKeyEventHandlerProtocol {
    func startSubscription() async
}

final class EncryptionKeyEventHandler: EncryptionKeyEventHandlerProtocol {
    
    @Injected(\.encryptionKeyService)
    private var encryptionKeyService: any EncryptionKeyServiceProtocol

    
    func startSubscription() async {
        for await events in await EventBunchSubscribtion.default.stream() {
            for event in events.middlewareEvents {
                switch event.value {
                case let .keyUpdate(data):
                    updateKey(data.encryptionKey, spaceId: data.spaceKeyID)
                default:
                    break
                }
            }
        }
    }
    
    private func updateKey(_ key: String, spaceId: String) {
        do {
            try encryptionKeyService.saveKey(key, spaceId: spaceId)
        } catch {
            anytypeAssertionFailure("Can't case encryption key", info: ["error": error.localizedDescription])
        }
    }
}
