import Foundation

public class UserSession {
    public static var shared = UserSession()
    
    public var focus: BlockFocusPosition?
    public var firstResponderId: BlockId?
    public var toggles: [BlockId : Bool] = [:]
}
