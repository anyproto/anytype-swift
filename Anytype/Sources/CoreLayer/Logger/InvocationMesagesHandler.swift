import Foundation
import Logger
import ProtobufMessages
import AnytypeCore

final class InvocationMesagesHandler: InvocationMesagesHandlerProtocol {
    
    func handle(message: InvocationMessage) {
        
        // Delete emoji. Pulse crash issue https://github.com/kean/PulsePro/issues/22
        let stringWithoutCombinedEmoji = message.responseJsonData
            .flatMap { String(data: $0, encoding: .utf8) }?
            .map { String($0.map { $0.isEmoji ? Character(" ") : $0 }) }

        let responseJsonData = stringWithoutCombinedEmoji?.data(using: .utf8)

        NetworkingLogger.logNetwork(
            name: message.name,
            requestData: message.requestJsonData,
            responseData: responseJsonData,
            responseError: message.responseError
        )
    }
    
    func handle(event: Anytype_ResponseEvent) {
        EventsBunch(event: event).send()
    }
    
    func assertationHandler(message: String, info: [String: String], file: StaticString) {
        anytypeAssertionFailure(message, info: info, file: file)
    }
}

private extension Character {
   var isSimpleEmoji: Bool {
      guard let firstProperties = unicodeScalars.first?.properties else {
        return false
      }
      return unicodeScalars.count == 1 &&
          (firstProperties.isEmojiPresentation ||
             firstProperties.generalCategory == .otherSymbol)
   }
   var isCombinedIntoEmoji: Bool {
      return unicodeScalars.count > 1 &&
             unicodeScalars.contains {
                $0.properties.isJoinControl ||
                $0.properties.isVariationSelector
             }
   }
   var isEmoji: Bool {
      return isSimpleEmoji || isCombinedIntoEmoji
   }
}
