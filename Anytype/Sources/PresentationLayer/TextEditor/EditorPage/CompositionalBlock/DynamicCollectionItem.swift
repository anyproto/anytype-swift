import Foundation

enum DynamicCollectionSection: CaseIterable {
    static var allCases: [DynamicCollectionSection] {
        fatalError()
    }

    case any(sectionId: String)
}

enum DynamicCollectionItem: Hashable {
    case simpleTableItem(SimpleTableBlockProtocol)

    static func == (lhs: DynamicCollectionItem, rhs: DynamicCollectionItem) -> Bool {
        switch (lhs, rhs) {
        case let (.simpleTableItem(lhsItem), .simpleTableItem(rhsItem)):
            return lhsItem.hashable == rhsItem.hashable
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .simpleTableItem(lhsItem):
            hasher.combine(lhsItem.hashable)
        }
    }
}
