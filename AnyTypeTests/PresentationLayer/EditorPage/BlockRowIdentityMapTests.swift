import Testing
@testable import Anytype

@MainActor
struct BlockRowIdentityMapTests {

    @Test func unknownIdResolvesToItself() {
        let map = BlockRowIdentityMap()
        #expect(map.rowId(for: "a") == "a")
        #expect(map.latestId(for: "a") == "a")
    }

    @Test func aliasResolvesBothDirections() {
        let map = BlockRowIdentityMap()
        #expect(map.register(newBlockId: "b", replacing: "a"))
        #expect(map.rowId(for: "b") == "a")
        #expect(map.latestId(for: "a") == "b")
        #expect(map.rowId(for: "a") == "a")
        #expect(map.latestId(for: "b") == "b")
    }

    @Test func chainsResolveTransitively() {
        // Fork a → b, b emptied and forked again → c.
        let map = BlockRowIdentityMap()
        #expect(map.register(newBlockId: "b", replacing: "a"))
        #expect(map.register(newBlockId: "c", replacing: "b"))
        #expect(map.rowId(for: "c") == "a")
        #expect(map.latestId(for: "a") == "c")
    }

    @Test func duplicateRegistrationsAreRefused() {
        let map = BlockRowIdentityMap()
        #expect(map.register(newBlockId: "b", replacing: "a"))
        // The same new id cannot land on two rows, one row cannot fork twice,
        // and an id cannot replace itself.
        #expect(!map.register(newBlockId: "b", replacing: "x"))
        #expect(!map.register(newBlockId: "y", replacing: "a"))
        #expect(!map.register(newBlockId: "z", replacing: "z"))
    }

    @Test func removeAliasRestoresIdentityResolution() {
        let map = BlockRowIdentityMap()
        #expect(map.register(newBlockId: "b", replacing: "a"))
        map.removeAlias(newBlockId: "b")
        #expect(map.rowId(for: "b") == "b")
        #expect(map.latestId(for: "a") == "a")
        // Both roles are free again.
        #expect(map.register(newBlockId: "b", replacing: "x"))
        #expect(map.register(newBlockId: "y", replacing: "a"))
    }

    @Test func pendingReplaceIsNotMistakenForUndo() {
        let map = BlockRowIdentityMap()
        #expect(map.register(newBlockId: "b", replacing: "a"))
        // The replace event has not applied yet: the document still lists the old id.
        #expect(map.undoneAliases(presentIds: ["a"]).isEmpty)
    }

    @Test func undoDetectedOnlyAfterReplaceWasSeenApplied() {
        let map = BlockRowIdentityMap()
        #expect(map.register(newBlockId: "b", replacing: "a"))
        // Replace applied…
        #expect(map.undoneAliases(presentIds: ["b"]).isEmpty)
        // …then undo removed the new id and restored the replaced one.
        let undone = map.undoneAliases(presentIds: ["a"])
        #expect(undone.count == 1)
        #expect(undone.first?.newBlockId == "b")
        #expect(undone.first?.replacedBlockId == "a")
    }

    @Test func newIdAbsentWithoutRestoredOldIdIsNotUndo() {
        let map = BlockRowIdentityMap()
        #expect(map.register(newBlockId: "b", replacing: "a"))
        #expect(map.undoneAliases(presentIds: ["b"]).isEmpty)
        // Both ids gone (block deleted outright) — nothing to rebind back to.
        #expect(map.undoneAliases(presentIds: []).isEmpty)
    }
}
