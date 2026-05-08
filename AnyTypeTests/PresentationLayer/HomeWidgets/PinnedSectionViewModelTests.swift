import Testing
import Foundation
import Combine
@testable import Anytype
import Services
import Factory
import AsyncTools

@Suite(.serialized)
@MainActor
struct PinnedSectionViewModelTests {

    private let recentStateManager: TestRecentStateManager
    private let participantsStorage: TestParticipantsStorage

    init() {
        let recentStateManager = TestRecentStateManager()
        let participantsStorage = TestParticipantsStorage()
        Container.shared.homeWidgetsRecentStateManager.register { recentStateManager }
        Container.shared.participantsStorage.register { participantsStorage }
        self.recentStateManager = recentStateManager
        self.participantsStorage = participantsStorage
    }

    // MARK: - init seed

    @Test func init_withWidgetBlocksInDoc_seedsWidgetBlocks() {
        let doc = makeDoc(widgetTargets: [AnytypeWidgetId.pinned.rawValue])

        let model = PinnedSectionViewModel(spaceId: "space-1", channelWidgetsObject: doc)

        #expect(model.widgetBlocks.count == 1)
        #expect(model.widgetBlocks.first?.source == .library(.pinned))
    }

    @Test func init_withEmptyDoc_seedsEmptyWidgetBlocks() {
        let doc = makeDoc(widgetTargets: [])

        let model = PinnedSectionViewModel(spaceId: "space-1", channelWidgetsObject: doc)

        #expect(model.widgetBlocks.isEmpty)
    }

    @Test func init_withUnresolvableWidget_filtersItOut() {
        let doc = makeDoc(widgetTargets: ["not-a-library-id-and-not-in-details"])

        let model = PinnedSectionViewModel(spaceId: "space-1", channelWidgetsObject: doc)

        #expect(model.widgetBlocks.isEmpty)
    }

    @Test func init_invokesRecentStateManager_once() {
        let doc = makeDoc(widgetTargets: [AnytypeWidgetId.recent.rawValue])

        _ = PinnedSectionViewModel(spaceId: "space-1", channelWidgetsObject: doc)

        #expect(recentStateManager.setupCallCount == 1)
    }

    // MARK: - subscription path

    @Test func subscription_emittingSameState_keepsWidgetBlocksEqual() async throws {
        let doc = makeDoc(widgetTargets: [AnytypeWidgetId.pinned.rawValue])
        let model = PinnedSectionViewModel(spaceId: "space-1", channelWidgetsObject: doc)
        let snapshot = model.widgetBlocks

        let task = Task { await model.startSubscriptions() }
        defer { task.cancel() }

        doc.simulateUpdate([.general])
        try await waitForBlocks(count: 1, on: model)

        #expect(model.widgetBlocks == snapshot)
    }

    @Test func subscription_emittingNewState_updatesWidgetBlocks() async throws {
        let doc = makeDoc(widgetTargets: [AnytypeWidgetId.pinned.rawValue])
        let model = PinnedSectionViewModel(spaceId: "space-1", channelWidgetsObject: doc)
        #expect(model.widgetBlocks.count == 1)

        let task = Task { await model.startSubscriptions() }
        defer { task.cancel() }

        let (newWidget, newLink) = makeWidgetAndLink(targetId: AnytypeWidgetId.recent.rawValue, suffix: "2")
        doc.mockChildren.append(newWidget)
        (doc.mockInfoContainer as! InfoContainerMock).getReturnInfo[newLink.id] = newLink

        doc.simulateUpdate([.general])
        try await waitForBlocks(count: 2, on: model)
    }

    // MARK: - Helpers

    private func makeDoc(widgetTargets: [String]) -> MockBaseDocument {
        let doc = MockBaseDocument(objectId: "channel-widgets-doc")
        let infoContainer = doc.mockInfoContainer as! InfoContainerMock

        for (index, target) in widgetTargets.enumerated() {
            let (widgetBlock, linkBlock) = makeWidgetAndLink(targetId: target, suffix: "\(index)")
            doc.mockChildren.append(widgetBlock)
            infoContainer.getReturnInfo[linkBlock.id] = linkBlock
        }

        return doc
    }

    private func makeWidgetAndLink(targetId: String, suffix: String) -> (BlockInformation, BlockInformation) {
        let widgetId = "widget-\(suffix)"
        let linkId = "link-\(suffix)"

        let widgetBlock = BlockInformation(
            id: widgetId,
            content: .widget(BlockWidget()),
            backgroundColor: nil,
            horizontalAlignment: .left,
            childrenIds: [linkId],
            configurationData: BlockInformationMetadata(backgroundColor: .default),
            fields: [:]
        )

        let linkBlock = BlockInformation(
            id: linkId,
            content: .link(BlockLink.empty(targetBlockID: targetId)),
            backgroundColor: nil,
            horizontalAlignment: .left,
            childrenIds: [],
            configurationData: BlockInformationMetadata(backgroundColor: .default),
            fields: [:]
        )

        return (widgetBlock, linkBlock)
    }

    private func waitForBlocks(count expected: Int, on model: PinnedSectionViewModel, timeoutMs: Int = 1000) async throws {
        let stepNs: UInt64 = 5_000_000
        let maxIterations = (timeoutMs * 1_000_000) / Int(stepNs)
        for _ in 0..<maxIterations {
            if model.widgetBlocks.count == expected { return }
            try await Task.sleep(nanoseconds: stepNs)
        }
        #expect(model.widgetBlocks.count == expected, "Timed out waiting for widgetBlocks.count == \(expected); got \(model.widgetBlocks.count)")
    }
}

// MARK: - Inline test mocks

private final class TestRecentStateManager: HomeWidgetsRecentStateManagerProtocol, @unchecked Sendable {
    private(set) var setupCallCount = 0

    func setupRecentStateIfNeeded(
        blocks: [BlockInformation],
        widgetObject: some BaseDocumentProtocol
    ) {
        setupCallCount += 1
    }
}

private final class TestParticipantsStorage: ParticipantsStorageProtocol, @unchecked Sendable {
    var participants: [Participant] { [] }

    var participantsSequence: AnyAsyncSequence<[Participant]> {
        AsyncStream<[Participant]> { _ in }.eraseToAnyAsyncSequence()
    }

    func startSubscription() async {}
    func stopSubscription() async {}
}
