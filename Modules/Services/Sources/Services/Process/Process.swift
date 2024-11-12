import Foundation
import ProtobufMessages

public struct Process: Sendable {
    public var id: String
    public var message: Anytype_Model.Process.OneOf_Message?
    public var state: Anytype_Model.Process.State
    public var progress: Anytype_Model.Process.Progress
}

extension Anytype_Model.Process {
    func asModel() -> Process {
        Process(id: id, message: message, state: state, progress: progress)
    }
}
