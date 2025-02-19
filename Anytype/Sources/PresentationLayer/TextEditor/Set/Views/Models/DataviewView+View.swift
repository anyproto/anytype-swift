import Foundation
import Services

extension DataviewView {
    var nameWithPlaceholder: String {
        name.isNotEmpty ? name : Loc.untitled
    }
}
