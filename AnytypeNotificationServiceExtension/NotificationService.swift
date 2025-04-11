import UserNotifications
import CommonCrypto
import CryptoKit
import Services

class NotificationService: UNNotificationServiceExtension {
    
    @Injected(\.encryptionKeyServiceShared)
    private var encryptionKeyServiceShared: any EncryptionKeyServiceSharedProtocol

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        // Extract encrypted data from the payload
        guard let encryptedBase64 = request.content.userInfo["x-any-payload"] as? String,
              let encryptedData = Data(base64Encoded: encryptedBase64),
              let spaceId = request.content.userInfo["x-any-key-id"] as? String,
              let keyString = try? encryptionKeyServiceShared.obtainKeyById(spaceId),
              let keyData = Data(base64Encoded: keyString)
//              let keyData = Data(base64Encoded: "caB+6JN9B+m8o5OKf9p4C8H0QVjfTNf+LRWHElkw7vI=")
        else {
            contentHandler(bestAttemptContent)
            return
        }
        
        // MARK: - Example Usage
        do {
            // 1. Create a symmetric key
            let key = SymmetricKey(data: Data(base64Encoded: "caB+6JN9B+m8o5OKf9p4C8H0QVjfTNf+LRWHElkw7vI=")!)

            // 2. Original plaintext data
            let originalMessage = "Secret Message".data(using: .utf8)!

            // 3. Encrypt the message
            let encryptedData = try encryptAESGCM(plaintext: originalMessage, key: key)
            print("Encrypted Data: \(encryptedData.base64EncodedString())")

            // 4. Decrypt the message
            let decryptedData = try decryptAESGCM(packedCiphertext: encryptedData, key: key)

            // 5. Convert decrypted data back to string
            if let decryptedMessage = String(data: decryptedData, encoding: .utf8) {
                print("Decrypted Message: \(decryptedMessage)")
            }
        } catch {
            print("Encryption/Decryption failed: \(error)")
        }

        
        do {
            
            let key = SymmetricKey(data: keyData)

            let plaintext = try decryptAESGCM22(packedCiphertext: encryptedData, key: key)
            
            bestAttemptContent.title = "Decrypted"

            // Convert plaintext to string if it's text-based
            if let decryptedString = String(data: plaintext, encoding: .utf8) {
                print("Decrypted text: \(decryptedString)")
            } else {
                print("Decrypted binary data: \(plaintext)")
            }
        } catch {
            print("Decryption failed: \(error)")
        }
        
        // Deliver the notification
        contentHandler(bestAttemptContent)
    }
    
    func encryptAESGCM(plaintext: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(plaintext, using: key)
        // Return the combined format: nonce + ciphertext + tag
        return sealedBox.combined!
    }
    
    // AES-GCM Decryption Function
    func decryptAESGCM22(packedCiphertext: Data, key: SymmetricKey) throws -> Data {
        // Check that data length is at least 12 bytes nonce + 16 bytes tag
        guard packedCiphertext.count > (12 + 16) else {
            throw NSError(domain: "Invalid data length", code: -1, userInfo: nil)
        }

        // Extract nonce (12 bytes)
        let nonceData = packedCiphertext.prefix(12)
        let tag = packedCiphertext.suffix(16)
        let ciphertext = packedCiphertext.dropLast(16).dropFirst(12)

        // Prepare nonce
        let nonce = try AES.GCM.Nonce(data: nonceData)
        
        print("Nonce (hex): \(nonceData.hexString)")
        print("Ciphertext (hex): \(ciphertext.hexString)")
        print("Tag (hex): \(tag.hexString)")

        // Decrypt using AES-GCM
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
        
        // Decrypt and return plaintext
        return try AES.GCM.open(sealedBox, using: key)
    }


    
    // AES-GCM Decryption Function
    func decryptAESGCM(packedCiphertext: Data, key: SymmetricKey) throws -> Data {
        // Check that data length is at least 12 bytes nonce + 16 bytes tag
        // Create a sealed box from the encrypted data. This assumes your encryptedData
        // is in the combined format: nonce + ciphertext + tag.
        let sealedBox = try AES.GCM.SealedBox(combined: packedCiphertext)

        // Use AES.GCM.open to decrypt the sealed box
        return try AES.GCM.open(sealedBox, using: key)
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Error Handling

enum CryptoError: Error {
    case invalidKeyOrIV
    case decryptionFailed(status: Int32)
}
