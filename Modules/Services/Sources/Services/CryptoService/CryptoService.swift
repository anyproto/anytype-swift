import Foundation
import CryptoKit

public protocol CryptoServiceProtocol: AnyObject, Sendable {
    func decryptAESGCM(data: Data, signatureData: Data, keyData: Data) throws -> Data
}

final class CryptoService: CryptoServiceProtocol {
    
    func decryptAESGCM(data: Data, signatureData: Data, keyData: Data) throws -> Data {
        guard verifyEd25519Signature(data: data, signatureData: signatureData, keyData: keyData) else {
            throw CryptoError.signatureFailed
        }
        let key = SymmetricKey(data: keyData)
        
        // Combined data format: nonce + ciphertext + tag
        let sealedBox = try AES.GCM.SealedBox(combined: data)

        // Use AES.GCM.open to decrypt the sealed box
        guard let decryptedData = try? AES.GCM.open(sealedBox, using: key) else {
            throw CryptoError.decryptionFailed
        }
        
        return decryptedData
    }
    
    func verifyEd25519Signature(data: Data, signatureData: Data, keyData: Data) -> Bool {
        guard let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: keyData) else {
            return false
        }
        
        return publicKey.isValidSignature(signatureData, for: data)
    }

}

public enum CryptoError: Error {
    case signatureFailed
    case decryptionFailed
}
