import Foundation
import Logger
import ProtobufMessages
import AnytypeCore

final class InvocationMesagesHandler: InvocationMesagesHandlerProtocol {
    
    var enableLogger: Bool = false
    
    func logHandler(message: InvocationMessage) {
        
        guard enableLogger else { return }
        
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
    
    func eventHandler(event: Anytype_ResponseEvent) async {
        await EventsBunch(event: event).send()
    }
    
    func assertationHandler(message: String, info: [String: String], file: StaticString, function: String, line: UInt) {
        anytypeAssertionFailure(message, info: info, file: file, function: function, line: line)
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
