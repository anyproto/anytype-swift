import Testing
@testable import Anytype

@MainActor
struct BlockRowIdentityMapTests {

    @Test func unaliasedIdResolvesToItself() {
        let map = BlockRowIdentityMap()
        #expect(map.rowId(for: "block-a") == "block-a")
    }

    @Test func aliasResolvesNewIdToReplacedRow() {
        let map = BlockRowIdentityMap()
        #expect(map.alias(newBlockId: "new", toRowOf: "old"))
        #expect(map.rowId(for: "new") == "old")
        #expect(map.rowId(for: "old") == "old")
    }

    @Test func chainResolvesTransitively() {
        // Virtual placeholder → created block → later fork of that block once it was emptied
        // again: every incarnation keeps the original row identity.
        let map = BlockRowIdentityMap()
        #expect(map.alias(newBlockId: "real", toRowOf: "virtual"))
        #expect(map.alias(newBlockId: "fork", toRowOf: "real"))
        #expect(map.rowId(for: "fork") == "virtual")
        #expect(map.rowId(for: "real") == "virtual")
    }

    @Test func repeatedAliasIsDeclinedAndKeepsFirstRegistration() {
        // A row's identity must never change once its identifier sits in an applied snapshot,
        // so a second registration for the same new id is declined — the caller must not
        // rebind on top of it.
        let map = BlockRowIdentityMap()
        #expect(map.alias(newBlockId: "new", toRowOf: "old-1"))
        #expect(!map.alias(newBlockId: "new", toRowOf: "old-2"))
        #expect(map.rowId(for: "new") == "old-1")
    }

    @Test func removeAliasRestoresOwnIdentityKeepingRestOfChain() {
        // The undo path removes only the undone link: the fork's id resolves to itself again
        // while the materialization link below it stays intact.
        let map = BlockRowIdentityMap()
        #expect(map.alias(newBlockId: "real", toRowOf: "virtual"))
        #expect(map.alias(newBlockId: "fork", toRowOf: "real"))
        map.removeAlias(newBlockId: "fork")
        #expect(map.rowId(for: "fork") == "fork")
        #expect(map.rowId(for: "real") == "virtual")
    }

    @Test func undoneAliasesMatchDirectPairsNotResolvedRoots() {
        // Undo restores exactly the replaced block, not the chain root: with the fork undone,
        // "real" is present again while the chain root "virtual" never reappears — the scan
        // must still match the fork's alias by its direct pair.
        let map = BlockRowIdentityMap()
        #expect(map.alias(newBlockId: "real", toRowOf: "virtual"))
        #expect(map.alias(newBlockId: "fork", toRowOf: "real"))
        let undone = map.undoneAliases(presentIds: ["real", "other"])
        #expect(undone.count == 1)
        #expect(undone.first?.newBlockId == "fork")
        #expect(undone.first?.replacedBlockId == "real")
    }

    @Test func undoneAliasesIgnoreLiveAndFullyGonePairs() {
        let map = BlockRowIdentityMap()
        #expect(map.alias(newBlockId: "live-new", toRowOf: "live-old"))
        #expect(map.alias(newBlockId: "gone-new", toRowOf: "gone-old"))
        // live-new present → its pair is a live rebind; the gone pair's replaced id is absent
        // → not an undo either.
        let undone = map.undoneAliases(presentIds: ["live-new"])
        #expect(undone.isEmpty)
    }
}
