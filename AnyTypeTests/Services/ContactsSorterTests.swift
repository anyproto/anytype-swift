import Testing
@testable import Anytype

@Suite
struct ContactsSorterTests {

    // MARK: - Group 1: Members with shared spaces

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

    @Test func sharedSpacesGroupSortsByNameNotGlobalName() {
        // Within the shared-spaces group, globalName should NOT affect order
        let contacts = [
            Contact(identity: "a", name: "Zoe", globalName: "zoe.any", icon: nil),
            Contact(identity: "b", name: "Alice", globalName: "", icon: nil)
        ]
        let spaceCounts = ["a": 2, "b": 2]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        // Alice before Zoe by name, even though Zoe has globalName
        #expect(sorted[0].identity == "b")
        #expect(sorted[1].identity == "a")
    }

    @Test func sortByNameWhenSpaceCountEqual() {
        let contacts = [
            Contact(identity: "a", name: "Zoe", globalName: "", icon: nil),
            Contact(identity: "b", name: "Alice", globalName: "", icon: nil),
            Contact(identity: "c", name: "Bob", globalName: "", icon: nil)
        ]
        let spaceCounts = ["a": 1, "b": 1, "c": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted.map(\.name) == ["Alice", "Bob", "Zoe"])
    }

    // MARK: - Group 2 & 3: Members with no shared spaces

    @Test func zeroSpacesGlobalNameBeforeNoGlobalName() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),
            Contact(identity: "b", name: "Bob", globalName: "bob.any", icon: nil)
        ]
        let spaceCounts: [String: Int] = [:]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b") // Bob has globalName
        #expect(sorted[1].identity == "a")
    }

    @Test func zeroSpacesBothHaveGlobalNameSortsByName() {
        let contacts = [
            Contact(identity: "a", name: "Zara", globalName: "zara.any", icon: nil),
            Contact(identity: "b", name: "Anna", globalName: "anna.any", icon: nil)
        ]
        let spaceCounts: [String: Int] = [:]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b") // Anna before Zara
    }

    @Test func zeroSpacesNoGlobalNameSortsByName() {
        let contacts = [
            Contact(identity: "a", name: "Zara", globalName: "", icon: nil),
            Contact(identity: "b", name: "Anna", globalName: "", icon: nil)
        ]
        let spaceCounts: [String: Int] = [:]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        #expect(sorted[0].identity == "b") // Anna before Zara
    }

    // MARK: - All three groups combined

    @Test func allThreeGroupsCombined() {
        let contacts = [
            Contact(identity: "a", name: "Alice", globalName: "", icon: nil),          // 0 spaces, no global → group 3
            Contact(identity: "b", name: "Bob", globalName: "bob.any", icon: nil),     // 2 spaces → group 1
            Contact(identity: "c", name: "Charlie", globalName: "", icon: nil),         // 2 spaces → group 1
            Contact(identity: "d", name: "Diana", globalName: "diana.any", icon: nil), // 0 spaces, global → group 2
            Contact(identity: "e", name: "Eve", globalName: "eve.any", icon: nil),     // 1 space → group 1
            Contact(identity: "f", name: "Frank", globalName: "", icon: nil)            // 0 spaces, no global → group 3
        ]
        let spaceCounts = ["b": 2, "c": 2, "e": 1]

        let sorted = ContactsSorter.sorted(contacts, spaceCounts: spaceCounts)

        // Group 1: shared spaces (sorted by count desc, then name)
        #expect(sorted[0].identity == "b") // 2 spaces, Bob
        #expect(sorted[1].identity == "c") // 2 spaces, Charlie
        #expect(sorted[2].identity == "e") // 1 space, Eve
        // Group 2: 0 spaces + has globalName (sorted by name)
        #expect(sorted[3].identity == "d") // Diana
        // Group 3: 0 spaces + no globalName (sorted by name)
        #expect(sorted[4].identity == "a") // Alice
        #expect(sorted[5].identity == "f") // Frank
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

        #expect(sorted[0].identity == "a") // 1 space
        #expect(sorted[1].identity == "b") // 0 spaces
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
}
