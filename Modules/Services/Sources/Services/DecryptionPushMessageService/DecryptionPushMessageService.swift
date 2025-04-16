import Foundation
import AnytypeCore

public protocol DecryptionPushMessageServiceProtocol: AnyObject, Sendable {
    func decrypt(_ encryptedData: Data, spaceId: String) -> DecryptedPushMessage?
}

final class DecryptionPushMessageService: DecryptionPushMessageServiceProtocol {
    
    private let cryptoService: any CryptoServiceProtocol = Container.shared.cryptoService()
    private let encryptionKeyService: any EncryptionKeyServiceProtocol = Container.shared.encryptionKeyService()
    
    func decrypt(_ encryptedData: Data, spaceId: String) -> DecryptedPushMessage? {
        do {
            let keyString = try encryptionKeyService.obtainKeyById(spaceId)
            
            guard let keyData = Data(base64Encoded: keyString) else {
                throw DecryptionPushMessageError.keyEncodeFailed
            }
            
            let decryptedData = try cryptoService.decryptAESGCM(data: encryptedData, keyData: keyData)
            let decoder = JSONDecoder()
            
            return try decoder.decode(DecryptedPushMessage.self, from: decryptedData)
        } catch {
            anytypeAssertionFailure(error.localizedDescription)
            return nil
        }
    }
}


public enum DecryptionPushMessageError: Error {
    case keyUndefined
    case keyEncodeFailed
}
