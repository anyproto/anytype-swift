import Services

protocol EncryptionKeyEventHandlerProtocol {
    func startSubscription() async
}

final class EncryptionKeyEventHandler: EncryptionKeyEventHandlerProtocol {
    
    @Injected(\.encryptionKeyService)
    private var encryptionKeyService: any EncryptionKeyServiceProtocol
    
    @Injected(\.encryptionKeyServiceShared)
    private var encryptionKeyServiceShared: any EncryptionKeyServiceSharedProtocol

    
    func startSubscription() async {
        for await events in await EventBunchSubscribtion.default.stream() {
            for event in events.middlewareEvents {
                switch event.value {
                case let .keyUpdate(data):
                    updateKey(data.encryptionKeyID, id: data.spaceKeyID)
                    try? encryptionKeyServiceShared.saveKey(data.encryptionKey, id: data.spaceKeyID)
                default:
                    break
                }
            }
        }
    }
    
    private func updateKey(_ key: String, id: String) {
        do {
            try encryptionKeyService.saveKey(key, id: id)
        } catch {
            
        }
    }
}
