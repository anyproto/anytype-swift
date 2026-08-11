import Foundation
import os

/// Mints block ids on the client in the outward shape the middleware mints them
/// (`bson.NewObjectId().Hex()`): 24 lowercase hex chars, 4 bytes of big-endian Unix time
/// first. The middle 8 bytes differ structurally — bson packs machine-hash + pid + counter,
/// this packs 5 bytes of per-process random + a 3-byte randomly seeded counter — which is
/// deliberate: 40 random bits beat a hostname hash for cross-client uniqueness, and nothing
/// downstream can distinguish them. The middleware generates an id only when the client
/// sends an empty one and accepts any non-empty id; keeping the outward shape (length,
/// hex alphabet, timestamp prefix) avoids exercising untested assumptions downstream of id
/// creation (sync, the change log, id-ordering heuristics).
///
/// Knowing the id at the call site — synchronously, before the RPC — is what keeps a row's
/// identity stable when a block is created or replaced under the caret: the editor binds
/// the row to its final id in the same turn as the keystroke instead of choreographing an
/// id swap one round trip later.
///
/// Uniqueness across clients comes from the random component, never from the replaced
/// block's id: two clients filling the same empty block concurrently must mint different
/// ids so both texts survive as two blocks (the IOS-6572 guarantee).
enum BlockIdGenerator {
    private static let processRandom: [UInt8] = (0..<5).map { _ in UInt8.random(in: .min ... .max) }
    private static let counter = OSAllocatedUnfairLock<UInt32>(initialState: .random(in: .min ... .max))

    static func mint(date: Date = Date()) -> String {
        let timestamp = UInt32(clamping: Int64(date.timeIntervalSince1970))
        let count = counter.withLock { state in
            state &+= 1
            return state
        }

        var bytes = [UInt8]()
        bytes.reserveCapacity(12)
        bytes.append(UInt8(truncatingIfNeeded: timestamp >> 24))
        bytes.append(UInt8(truncatingIfNeeded: timestamp >> 16))
        bytes.append(UInt8(truncatingIfNeeded: timestamp >> 8))
        bytes.append(UInt8(truncatingIfNeeded: timestamp))
        bytes.append(contentsOf: processRandom)
        bytes.append(UInt8(truncatingIfNeeded: count >> 16))
        bytes.append(UInt8(truncatingIfNeeded: count >> 8))
        bytes.append(UInt8(truncatingIfNeeded: count))

        return bytes.reduce(into: "") { $0 += String(format: "%02x", $1) }
    }
}
