import Foundation
import Combine
import ProtobufMessages

public protocol BlockActionsServiceSingleProtocol: AnyObject {
    func close(contextId: String) async throws
    func open(contextId: String) async throws -> ObjectViewModel
    func openForPreview(contextId: String) async throws -> ObjectViewModel
}
