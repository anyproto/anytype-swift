import Foundation

extension String {
    var withPlaceholder: String {
        return isEmpty ? Loc.Object.Title.placeholder : self
    }
}
