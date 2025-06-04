import Foundation
import CryptoKit
import AnyCryptoSwift

protocol CryptoServiceProtocol: AnyObject, Sendable {
    func decryptAESGCM(data: Data, keyData: Data) throws -> Data
    func isValidSignature(senderId: String, signatureData: Data, encryptedData: Data) throws -> Bool
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
    
    func isValidSignature(senderId: String, signatureData: Data, encryptedData: Data) throws -> Bool {
        do {
            let pubKey = try AnyCryptoSwift.decodeAccountAddress(senderId)
            return try pubKey.verify(data: encryptedData, signature: signatureData)
        } catch {
            throw CryptoError.signatureFailed
        }
    }
}

enum CryptoError: Error {
    case decryptionFailed
    case signatureFailed
}
