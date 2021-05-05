import Foundation

struct DocumentSection: Hashable {
    let section: Int
    static var first: Self = .init(section: 0)
}

