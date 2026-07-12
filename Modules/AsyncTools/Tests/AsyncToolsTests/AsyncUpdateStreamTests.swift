import Testing
@testable import AsyncTools

private enum Update: Hashable, CaseIterable, Sendable {
    case messages
    case state
    case messageCount
}

struct AsyncUpdateStreamTests {

    @Test func seedIsDeliveredToNewSubscriber() async {
        let stream = AsyncUpdateStream<Update>(seed: Set(Update.allCases))
        let iterator = stream.makeAsyncIterator()

        let first = await iterator.next()

        #expect(first == Set(Update.allCases))
    }

    @Test func emptySendIsNoOp() async {
        let stream = AsyncUpdateStream<Update>()
        let iterator = stream.makeAsyncIterator()

        stream.send([])
        stream.send([.messages])

        let first = await iterator.next()
        #expect(first == [.messages])
    }

    @Test func pendingUpdatesAreUnioned() async {
        let stream = AsyncUpdateStream<Update>()
        let iterator = stream.makeAsyncIterator()

        // Sent while the subscriber is not awaiting — must merge, not overwrite
        stream.send([.messages])
        stream.send([.state])
        stream.send([])

        let first = await iterator.next()
        #expect(first == [.messages, .state])
    }

    @Test func sendResumesAwaitingSubscriber() async {
        let stream = AsyncUpdateStream<Update>()
        let iterator = stream.makeAsyncIterator()

        async let value = iterator.next()
        // Give next() a chance to suspend before sending
        await Task.yield()
        stream.send([.state])

        let received = await value
        #expect(received == [.state])
    }

    @Test func subscribersAreIndependent() async {
        let stream = AsyncUpdateStream<Update>()
        let fast = stream.makeAsyncIterator()
        let slow = stream.makeAsyncIterator()

        stream.send([.messages])
        let fastFirst = await fast.next()
        #expect(fastFirst == [.messages])

        stream.send([.state])
        let fastSecond = await fast.next()
        #expect(fastSecond == [.state])

        // The slow subscriber gets the union of both sends
        let slowFirst = await slow.next()
        #expect(slowFirst == [.messages, .state])
    }

    @Test func pendingIsClearedAfterDelivery() async {
        let stream = AsyncUpdateStream<Update>(seed: [.messages])
        let iterator = stream.makeAsyncIterator()

        _ = await iterator.next()
        stream.send([.state])

        let second = await iterator.next()
        #expect(second == [.state])
    }

    @Test func cancellationFinishesIteration() async {
        let stream = AsyncUpdateStream<Update>()

        let task = Task {
            var received = [Set<Update>]()
            for await updates in stream {
                received.append(updates)
            }
            return received
        }

        await Task.yield()
        task.cancel()

        let received = await task.value
        #expect(received.isEmpty)
    }

    @Test func noUpdatesLostUnderConcurrentSends() async {
        let stream = AsyncUpdateStream<Int>()
        let iterator = stream.makeAsyncIterator()

        await withTaskGroup(of: Void.self) { group in
            for value in 0..<100 {
                group.addTask {
                    stream.send([value])
                }
            }
        }

        var received = Set<Int>()
        while received.count < 100, let updates = await iterator.next() {
            received.formUnion(updates)
        }
        #expect(received == Set(0..<100))
    }
}
