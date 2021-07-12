import Foundation

public class UserSession {
    public var focus: BlockFocusPosition?
    public var firstResponder: BlockModelProtocol?
    public var toggles: [BlockId : Bool] = [:]
}
