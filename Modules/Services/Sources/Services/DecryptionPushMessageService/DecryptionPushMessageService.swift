import Foundation
import AnytypeCore

public protocol DecryptionPushMessageServiceProtocol: AnyObject { // Sendable shoould be
    func decrypt(_ encryptedData: Data, spaceId: String) -> DecryptedPushMessage?
}

final class DecryptionPushMessageService: DecryptionPushMessageServiceProtocol {
    
    private let cryptoService: any CryptoServiceProtocol = Container.shared.cryptoService()
    private let encryptionKeyServiceShared: any EncryptionKeyServiceSharedProtocol = Container.shared.encryptionKeyServiceShared()
    
    func decrypt(_ encryptedData: Data, spaceId: String) -> DecryptedPushMessage? {
        do {
            guard let keyString = try encryptionKeyServiceShared.obtainKeyById(spaceId) else {
                throw DecryptionPushMessageError.keyUndefined
            }
            
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
