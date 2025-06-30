import Foundation
import AnytypeCore

public protocol DecryptionPushContentServiceProtocol: AnyObject, Sendable {
    func decrypt(_ encryptedData: Data, keyId: String) -> DecryptedPushContent?
    func isValidSignature(senderId: String, signatureData: Data, encryptedData: Data) -> Bool
}

public final class DecryptionPushContentService: DecryptionPushContentServiceProtocol {
    
    private let cryptoService: any CryptoServiceProtocol = CryptoService()
    private let encryptionKeyService: any EncryptionKeyServiceProtocol = EncryptionKeyService()
    private let decoder = JSONDecoder()
    
    public init() {}
    
    public func decrypt(_ encryptedData: Data, keyId: String) -> DecryptedPushContent? {
        do {
            let keyString = try encryptionKeyService.obtainKeyById(keyId)
            
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
    
    public func isValidSignature(senderId: String, signatureData: Data, encryptedData: Data) -> Bool {
        do {
            return try cryptoService.isValidSignature(
                senderId: senderId,
                signatureData: signatureData,
                encryptedData: encryptedData
            )
        } catch {
            anytypeAssertionFailure(error.localizedDescription)
            return false
        }
    }
}


enum DecryptionPushContentError: Error {
    case keyEncodeFailed
}
