import Foundation
import Testing
import AnytypeCore
import Services
@testable import Anytype

struct UnifiedSearchTypeSorterTests {

    @Test func sorted_ordersByLastUsedDateDescendingThenNameAscending() {
        let sameDate = Date(timeIntervalSince1970: 200)
        let types = [
            makeType(id: "unused", uniqueKey: "unused", name: "Unused", lastUsedDate: nil),
            makeType(id: "task", uniqueKey: "task", name: "Task", lastUsedDate: sameDate),
            makeType(id: "alpha", uniqueKey: "alpha", name: "Alpha", lastUsedDate: sameDate),
            makeType(id: "latest", uniqueKey: "latest", name: "Latest", lastUsedDate: Date(timeIntervalSince1970: 300))
        ]

        let result = UnifiedSearchTypeSorter.sorted(types, deduplicateByUniqueKey: false)

        #expect(result.map(\.id) == ["latest", "alpha", "task", "unused"])
    }

    @Test func sorted_deduplicatesByUniqueKeyKeepingMostRecentlyUsedInstance() {
        let types = [
            makeType(id: "page-old", uniqueKey: "page", name: "Page", lastUsedDate: Date(timeIntervalSince1970: 100)),
            makeType(id: "page-new", uniqueKey: "page", name: "Page", lastUsedDate: Date(timeIntervalSince1970: 300)),
            makeType(id: "task", uniqueKey: "task", name: "Task", lastUsedDate: Date(timeIntervalSince1970: 200))
        ]

        let result = UnifiedSearchTypeSorter.sorted(types, deduplicateByUniqueKey: true)

        #expect(result.map(\.id) == ["page-new", "task"])
    }

    private func makeType(
        id: String,
        uniqueKey: String,
        name: String,
        lastUsedDate: Date?
    ) -> ObjectDetails {
        var values = [
            BundledPropertyKey.name.rawValue: name.protobufValue,
            BundledPropertyKey.uniqueKey.rawValue: uniqueKey.protobufValue
        ]
        if let lastUsedDate {
            values[BundledPropertyKey.lastUsedDate.rawValue] = lastUsedDate.protobufValue
        }
        return ObjectDetails(id: id, values: values)
    }
}
