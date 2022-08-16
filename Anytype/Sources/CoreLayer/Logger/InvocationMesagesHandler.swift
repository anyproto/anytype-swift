import Foundation
import Logger
import ProtobufMessages

final class InvocationMesagesHandler: InvocationMesagesHandlerProtocol {
    
    func handle(message: InvocationMessage) {
        NetworkingLogger.logNetwork(
            name: message.name,
            requestData: message.requestJsonData,
            responseData: message.responseJsonData,
            responseError: message.responseError
        )
    }
}
