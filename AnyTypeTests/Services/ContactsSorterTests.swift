import Testing
@testable import Anytype

@Suite
struct ContactsSorterTests {

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

    @Test func sortByGlobalNamePresenceWhenSpaceCountEqual() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),
            Contact(identity: "b", name: "Bob", globalName: "bob.any", icon: nil),
            Contact(identity: "c", name: "Charlie", globalName: "", icon: nil)
        ]
        let spaceCounts = ["a": 2, "b": 2, "c": 2]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b")
    }

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

    @Test func allThreeCriteriaCombined() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),        // 1 space, no global
            Contact(identity: "b", name: "Bob", globalName: "bob.any", icon: nil),   // 2 spaces, global
            Contact(identity: "c", name: "Charlie", globalName: "", icon: nil),       // 2 spaces, no global
            Contact(identity: "d", name: "Diana", globalName: "diana.any", icon: nil),// 2 spaces, global
            Contact(identity: "e", name: "Eve", globalName: "eve.any", icon: nil)     // 1 space, global
        ]
        let spaceCounts = ["a": 1, "b": 2, "c": 2, "d": 2, "e": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        // 2 spaces + global name: Bob, Diana (alphabetical)
        #expect(sorted[0].identity == "b")
        #expect(sorted[1].identity == "d")
        // 2 spaces + no global name: Charlie
        #expect(sorted[2].identity == "c")
        // 1 space + global name: Eve
        #expect(sorted[3].identity == "e")
        // 1 space + no global name: Alice
        #expect(sorted[4].identity == "a")
    }

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
        let spaceCounts = ["a": 1] // "b" missing

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "a")
        #expect(sorted[1].identity == "b")
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

    @Test func bothHaveGlobalNameSortsByName() {
        let contacts = [
            Contact(identity: "a", name: "Zara", globalName: "zara.any", icon: nil),
            Contact(identity: "b", name: "Anna", globalName: "anna.any", icon: nil)
        ]
        let spaceCounts = ["a": 1, "b": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b") // Anna before Zara
    }
}
