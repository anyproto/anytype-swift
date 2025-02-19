import Foundation

extension String {
    var withPlaceholder: String {
        return isEmpty ? Loc.untitled : self
    }
}
