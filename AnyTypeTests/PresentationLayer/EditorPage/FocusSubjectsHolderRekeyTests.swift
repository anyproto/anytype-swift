import Testing
import Combine
@testable import Anytype
import Services

struct FocusSubjectsHolderRekeyTests {

    @Test func rekeyMovesTheSameSubjectInstanceToTheNewId() {
        let holder = FocusSubjectsHolder()
        let subject = holder.focusSubject(for: "a")

        holder.rekeySubject(from: "a", to: "b")

        // Id-keyed sends for the new id reach the original subscribers.
        var received = [BlockFocusPosition]()
        let cancellable = subject.sink { received.append($0) }
        holder.focusSubject(for: "b").send(.beginning)
        #expect(received.count == 1)
        cancellable.cancel()

        // The old key is free again and yields a fresh, unrelated subject.
        #expect(holder.focusSubject(for: "a") !== subject)
    }

    @Test func rekeyWithoutExistingSubjectIsANoOp() {
        let holder = FocusSubjectsHolder()
        holder.rekeySubject(from: "missing", to: "b")

        // No subject was moved; "b" is created on demand as usual.
        let subject = holder.focusSubject(for: "b")
        #expect(holder.focusSubject(for: "b") === subject)
    }
}
