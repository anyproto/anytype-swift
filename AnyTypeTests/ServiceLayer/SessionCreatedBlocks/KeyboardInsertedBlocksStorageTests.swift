import Testing
@testable import Anytype

@MainActor
struct KeyboardInsertedBlocksStorageTests {

    @Test func consumeReturnsOnlyMatchingIdsAndRemovesThem() {
        let storage = KeyboardInsertedBlocksStorage()
        storage.register(blockId: "a")
        storage.register(blockId: "b")

        #expect(storage.consume(in: ["b", "x"]) == ["b"])
        // Consumed ids are gone; unconsumed ones stay pending.
        #expect(storage.consume(in: ["b"]) == [])
        #expect(storage.consume(in: ["a"]) == ["a"])
    }

    @Test func consumeWithNoMatchesLeavesPendingIdsIntact() {
        let storage = KeyboardInsertedBlocksStorage()
        storage.register(blockId: "a")

        #expect(storage.consume(in: ["x", "y"]) == [])
        #expect(storage.consume(in: ["a"]) == ["a"])
    }

    @Test func registrationIsDeduplicated() {
        let storage = KeyboardInsertedBlocksStorage()
        storage.register(blockId: "a")
        storage.register(blockId: "a")

        #expect(storage.consume(in: ["a"]) == ["a"])
        #expect(storage.consume(in: ["a"]) == [])
    }

    @Test func evictionDropsTheOldestPendingId() {
        let storage = KeyboardInsertedBlocksStorage()
        for index in 0...64 {
            storage.register(blockId: "id-\(index)")
        }

        // Capacity is 64: registering the 65th evicts the oldest.
        #expect(storage.consume(in: ["id-0"]) == [])
        #expect(storage.consume(in: ["id-1", "id-64"]) == ["id-1", "id-64"])
    }
}
