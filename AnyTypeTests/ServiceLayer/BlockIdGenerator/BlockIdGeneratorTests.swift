import Testing
import Foundation
@testable import Anytype

// Serialized so this suite's own tests cannot mint between the two back-to-back mints of
// the counter-increment expectation. Note `.serialized` orders tests within this suite
// only; the expectation additionally relies on no other suite calling `mint()` — if one
// ever does, relax the counter test to tolerate gaps.
@Suite(.serialized)
struct BlockIdGeneratorTests {

    @Test func mintedIdHasBsonObjectIdShape() {
        let id = BlockIdGenerator.mint()
        #expect(id.count == 24)
        #expect(id.allSatisfy { $0.isHexDigit && (!$0.isLetter || $0.isLowercase) })
    }

    @Test func timestampPrefixEncodesBigEndianUnixTime() {
        let date = Date(timeIntervalSince1970: 0x65a1_b2c3)
        let id = BlockIdGenerator.mint(date: date)
        #expect(id.hasPrefix("65a1b2c3"))
    }

    @Test func timestampBeforeEpochClampsToZero() {
        let id = BlockIdGenerator.mint(date: Date(timeIntervalSince1970: -1))
        #expect(id.hasPrefix("00000000"))
    }

    @Test func randomComponentIsStablePerProcess() {
        let first = BlockIdGenerator.mint()
        let second = BlockIdGenerator.mint()
        let randomRange = { (id: String) in
            id.dropFirst(8).prefix(10)
        }
        #expect(randomRange(first) == randomRange(second))
    }

    @Test func counterIncrementsBetweenMints() {
        let date = Date()
        let first = BlockIdGenerator.mint(date: date)
        let second = BlockIdGenerator.mint(date: date)
        let counter = { (id: String) in
            UInt32(id.suffix(6), radix: 16)!
        }
        // The 3-byte counter wraps; consecutive mints differ by exactly one modulo 2^24.
        #expect((counter(second) &- counter(first)) & 0xFFFFFF == 1)
    }

    @Test func mintedIdsAreUnique() {
        var seen = Set<String>()
        for _ in 0..<10_000 {
            seen.insert(BlockIdGenerator.mint())
        }
        #expect(seen.count == 10_000)
    }

    @Test func concurrentMintsAreUnique() async {
        let ids = await withTaskGroup(of: [String].self, returning: Set<String>.self) { group in
            for _ in 0..<8 {
                group.addTask {
                    (0..<1000).map { _ in BlockIdGenerator.mint() }
                }
            }
            var all = Set<String>()
            for await chunk in group {
                all.formUnion(chunk)
            }
            return all
        }
        #expect(ids.count == 8000)
    }
}
