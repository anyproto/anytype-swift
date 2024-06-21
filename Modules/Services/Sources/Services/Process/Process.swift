import Foundation
import ProtobufMessages

public struct Process: Sendable {
    public var id: String
    public var type: Anytype_Model.Process.TypeEnum
    public var state: Anytype_Model.Process.State
    public var progress: Anytype_Model.Process.Progress
}

extension Anytype_Model.Process {
    func asModel() -> Process {
        Process(id: id, type: type, state: state, progress: progress)
    }
}
