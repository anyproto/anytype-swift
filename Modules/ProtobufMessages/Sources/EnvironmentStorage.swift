import Foundation
import Lib

public struct EnvironmentStorage {
    public static func setEnv(key: String, value: String) {
        Lib.ServiceSetEnv(key, value)
    }
}
