import Foundation
import AnytypeCore

public protocol DecryptionPushContentServiceProtocol: AnyObject, Sendable {
    func decrypt(_ encryptedData: Data, spaceId: String) -> DecryptedPushContent?
}

final class DecryptionPushContentService: DecryptionPushContentServiceProtocol {
    
    private let cryptoService: any CryptoServiceProtocol = Container.shared.cryptoService()
    private let encryptionKeyService: any EncryptionKeyServiceProtocol = Container.shared.encryptionKeyService()
    private let decoder = JSONDecoder()
    
    func decrypt(_ encryptedData: Data, spaceId: String) -> DecryptedPushContent? {
        do {
            let keyString = try encryptionKeyService.obtainKeyById(spaceId)
            
            guard let keyData = Data(base64Encoded: keyString) else {
                throw DecryptionPushContentError.keyEncodeFailed
            }
            
            let decryptedData = try cryptoService.decryptAESGCM(data: encryptedData, keyData: keyData)
            
            return try decoder.decode(DecryptedPushContent.self, from: decryptedData)
        } catch {
            anytypeAssertionFailure(error.localizedDescription)
            return nil
        }
    }
}


public enum DecryptionPushContentError: Error {
    case keyEncodeFailed
}
