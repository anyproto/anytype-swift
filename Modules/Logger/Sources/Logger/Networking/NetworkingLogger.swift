import Foundation
import Pulse
import PulseCore

public final class NetworkingLogger {
    
    public static func logNetwork(
        name: String,
        requestData: Data?,
        responseData: Data?,
        responseError: Error?
    ) {
        guard let url = URL(string: name)  else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PROTO"
        request.httpBody = requestData
        let response = HTTPURLResponse(
            url: url,
            statusCode: (responseError as? NSError)?.code ?? 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        LoggerStore.default.storeRequest(
            request,
            response: response,
            error: responseError,
            data: responseData
        )
    }
}
