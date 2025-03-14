import Foundation
import CryptoKit
import AnytypeCore
import Services


final class PromoTierJWTGenerator {
    // Temporary promo tiers for AnyApp
    func promoTierReceiptString(account: AccountData) -> String? {
        do {
            // Step 1: Retrieve Secret from Info.plist
            guard let secret = Bundle.main.object(forInfoDictionaryKey: "AnyAppMembershipTierSecret") as? String else {
                print("Error: Secret not found in Info.plist")
                return nil
            }
            
            // Step 2: Generate a Private Key (Temporary Key for Signing)
            let privateKey = P256.Signing.PrivateKey()
            
            // Step 3: Create a JSON Payload
            let payloadDict: [String: Any] = [
                "ProductID": account.id,
                "BundleID": "pioneer",
                "OfferIdentifier": secret,
                "AppAccountToken": account.info.ethereumAddress
            ]
            
            // Convert JSON to Data
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payloadDict, options: []) else {
                anytypeAssertionFailure("Error: Failed to encode payload JSON")
                return nil
            }
            let payloadBase64 = jsonData.base64EncodedString()
            
            // Step 4: Create the JWS Header
            let headerDict: [String: Any] = [
                "alg": "ES256",  // Algorithm
                "typ": "JWT"     // Type
            ]
            
            // Convert header to Data
            guard let headerData = try? JSONSerialization.data(withJSONObject: headerDict, options: []) else {
                anytypeAssertionFailure("Error: Failed to encode header JSON")
                return nil
            }
            let headerBase64 = headerData.base64EncodedString()
            
            // Step 5: Create the Signing Input
            let signingInput = "\(headerBase64).\(payloadBase64)"
            guard let signingInputData = signingInput.data(using: .utf8) else {
                anytypeAssertionFailure("Error: Failed to encode signing input")
                return nil
            }
            
            // Step 6: Generate a Signature
            let signature = try privateKey.signature(for: signingInputData)
            
            // Convert Signature to Base64
            let signatureBase64 = signature.derRepresentation.base64EncodedString()
            
            // Step 7: Construct the Final JWS String
            let jwsString = "\(signingInput).\(signatureBase64)"
            
            return jwsString
        } catch {
            anytypeAssertionFailure("Error generating JWS: \(error)")
            return nil
        }
    }
    
}
