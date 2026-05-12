import Foundation
import Lib

public struct DebugServerRunner {
    public static func run(addr: String) {
        Lib.ServiceRunDebugServer(addr)
    }
}
