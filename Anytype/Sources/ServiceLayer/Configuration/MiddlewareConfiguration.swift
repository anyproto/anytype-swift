import ProtobufMessages
import Services

struct MiddlewareConfiguration: Hashable {
    let gatewayURL: String
}

extension MiddlewareConfiguration {
    
    init(info: AccountInfo) {
        self.gatewayURL = info.gatewayURL
    }
    
}

extension MiddlewareConfiguration {
    
    static let empty = MiddlewareConfiguration(
        gatewayURL: ""
    )
    
}
