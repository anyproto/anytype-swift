import Testing
@testable import Anytype

@Suite
struct ContactsSorterTests {

    // MARK: - Space count sorting

    @Test func sortBySpaceCountDescending() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),
            Contact(identity: "b", name: "Bob", globalName: "", icon: nil),
            Contact(identity: "c", name: "Charlie", globalName: "", icon: nil)
        ]
        let spaceCounts = ["a": 1, "b": 3, "c": 2]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted.map(\.identity) == ["b", "c", "a"])
    }

    // MARK: - AnyName sorting

    @Test func globalNameFirstWhenSpaceCountEqual() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),
            Contact(identity: "b", name: "Bob", globalName: "bob.any", icon: nil)
        ]
        let spaceCounts = ["a": 2, "b": 2]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b")
    }

    @Test func bothHaveGlobalNameSortsByName() {
        let contacts = [
            Contact(identity: "a", name: "Zara", globalName: "zara.any", icon: nil),
            Contact(identity: "b", name: "Anna", globalName: "anna.any", icon: nil)
        ]
        let spaceCounts = ["a": 1, "b": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b") // Anna before Zara
    }

    // MARK: - Name sorting

    @Test func sortByNameWhenSpaceCountAndGlobalNameEqual() {
        let contacts = [
            Contact(identity: "a", name: "Zoe", globalName: "", icon: nil),
            Contact(identity: "b", name: "Alice", globalName: "", icon: nil),
            Contact(identity: "c", name: "Bob", globalName: "", icon: nil)
        ]
        let spaceCounts = ["a": 1, "b": 1, "c": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted.map(\.name) == ["Alice", "Bob", "Zoe"])
    }

    @Test func nameSortIsCaseInsensitive() {
        let contacts = [
            Contact(identity: "a", name: "bob", globalName: "", icon: nil),
            Contact(identity: "b", name: "Alice", globalName: "", icon: nil)
        ]
        let spaceCounts = ["a": 1, "b": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b") // "Alice" before "bob"
    }

    // MARK: - All criteria combined

    @Test func allCriteriaCombined() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),          // 1 space, no AnyName
            Contact(identity: "b", name: "Bob", globalName: "bob.any", icon: nil),     // 3 spaces, AnyName
            Contact(identity: "c", name: "Charlie", globalName: "", icon: nil),         // 3 spaces, no AnyName
            Contact(identity: "d", name: "Diana", globalName: "diana.any", icon: nil), // 1 space, AnyName
            Contact(identity: "e", name: "Eve", globalName: "eve.any", icon: nil)      // 1 space, AnyName
        ]
        let spaceCounts = ["a": 1, "b": 3, "c": 3, "d": 1, "e": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        // 3 spaces + AnyName: Bob
        #expect(sorted[0].identity == "b")
        // 3 spaces + no AnyName: Charlie
        #expect(sorted[1].identity == "c")
        // 1 space + AnyName: Diana, Eve (alphabetical)
        #expect(sorted[2].identity == "d")
        #expect(sorted[3].identity == "e")
        // 1 space + no AnyName: Alice
        #expect(sorted[4].identity == "a")
    }

    // MARK: - Edge cases

    @Test func emptyContactsReturnsEmpty() {
        let sorted = ContactsSorter.sorted([], spaceCounts: [:])

        #expect(sorted.isEmpty)
    }

    @Test func singleContactReturnsSame() {
        let contacts = [Contact(identity: "a", name: "Alice", globalName: "alice.any", icon: nil)]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: ["a": 1])

        #expect(sorted.count == 1)
        #expect(sorted[0].identity == "a")
    }

    @Test func missingSpaceCountTreatedAsZero() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),
            Contact(identity: "b", name: "Bob", globalName: "", icon: nil)
        ]
        let spaceCounts = ["a": 1] // "b" missing → treated as 0

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "a")
        #expect(sorted[1].identity == "b")
    }
}
