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
              let keyData = try? encryptionKeyServiceShared.obtainKeyById(spaceId) else {
            contentHandler(bestAttemptContent)
            return
        }
        
        do {
            
            let key = SymmetricKey(data: keyData)

            let plaintext = try decryptAESGCM(packedCiphertext: encryptedData, key: key)
            
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

// MARK: - Error Handling

enum CryptoError: Error {
    case invalidKeyOrIV
    case decryptionFailed(status: Int32)
}
