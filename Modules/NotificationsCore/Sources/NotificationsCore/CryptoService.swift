import Foundation
import CryptoKit

protocol CryptoServiceProtocol: AnyObject, Sendable {
    func decryptAESGCM(data: Data, keyData: Data) throws -> Data
}

final class CryptoService: CryptoServiceProtocol {
    
    func decryptAESGCM(data: Data, keyData: Data) throws -> Data {
        let key = SymmetricKey(data: keyData)
        
        // Combined data format: nonce + ciphertext + tag
        let sealedBox = try AES.GCM.SealedBox(combined: data)

        // Use AES.GCM.open to decrypt the sealed box
        guard let decryptedData = try? AES.GCM.open(sealedBox, using: key) else {
            throw CryptoError.decryptionFailed
        }
        
        return decryptedData
    }
}

enum CryptoError: Error {
    case decryptionFailed
}
