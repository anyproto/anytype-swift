import Foundation
import Services

extension NetworkServerConfig {
    
    var title: String {
        switch self {
        case .anytype:
            return Loc.Server.anytype
        case .localOnly:
            return Loc.Server.localOnly
        case .file(let name):
            return name
        }
    }
}
