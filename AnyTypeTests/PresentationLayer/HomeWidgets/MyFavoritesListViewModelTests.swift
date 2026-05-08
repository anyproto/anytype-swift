import Testing
import Foundation
import Combine
@testable import Anytype
import Services
import AnytypeCore
import SwiftProtobuf

@Suite(.serialized)
@MainActor
struct MyFavoritesListViewModelTests {

    // MARK: - init seed

    @Test func init_withFavoriteWidgetsInDoc_seedsRows() {
        let doc = makeDoc(targets: [
            .object(id: "obj-a", layout: .basic),
            .object(id: "obj-b", layout: .basic)
        ])

        let model = makeModel(personalDoc: doc)

        #expect(model.rows.count == 2)
        #expect(model.rows.map(\.details.id) == ["obj-a", "obj-b"])
    }

    @Test func init_withEmptyDoc_seedsEmptyRows() {
        let doc = makeDoc(targets: [])

        let model = makeModel(personalDoc: doc)

        #expect(model.rows.isEmpty)
    }

    @Test func init_withDeletedTarget_filtersRowOut() {
        let doc = makeDoc(targets: [
            .object(id: "obj-alive", layout: .basic),
            .object(id: "obj-dead", layout: .basic, isDeleted: true)
        ])

        let model = makeModel(personalDoc: doc)

        #expect(model.rows.map(\.details.id) == ["obj-alive"])
    }

    @Test func init_withArchivedTarget_filtersRowOut() {
        let doc = makeDoc(targets: [
            .object(id: "obj-alive", layout: .basic),
            .object(id: "obj-archived", layout: .basic, isArchived: true)
        ])

        let model = makeModel(personalDoc: doc)

        #expect(model.rows.map(\.details.id) == ["obj-alive"])
    }

    @Test func init_withUnsupportedLayout_filtersRowOut() {
        // No `resolvedLayout` set → DetailsLayout resolves to .UNRECOGNIZED, which fails isSupportedForOpening.
        let doc = makeDoc(targets: [
            .object(id: "obj-supported", layout: .basic),
            .object(id: "obj-no-layout", layout: nil)
        ])

        let model = makeModel(personalDoc: doc)

        #expect(model.rows.map(\.details.id) == ["obj-supported"])
    }

    @Test func init_withLibrarySourceWidget_filtersRowOut() {
        // Library widgets (e.g. Pinned) belong to the channel doc, not personal favorites.
        // If one slips into the personal doc, the .object(details) match should drop it.
        let doc = makeDoc(targets: [
            .object(id: "obj-a", layout: .basic),
            .library(id: AnytypeWidgetId.pinned.rawValue)
        ])

        let model = makeModel(personalDoc: doc)

        #expect(model.rows.map(\.details.id) == ["obj-a"])
    }

    // MARK: - subscription path

    @Test func subscription_emittingSameStructure_keepsRowsIdentical() async throws {
        let doc = makeDoc(targets: [.object(id: "obj-a", layout: .basic)])
        let model = makeModel(personalDoc: doc)
        let snapshot = model.rows

        let task = Task { await model.startSubscriptions() }
        defer { task.cancel() }

        doc.simulateUpdate([.general])
        try await waitForRows(count: 1, on: model)

        #expect(model.rows.map(\.id) == snapshot.map(\.id))
    }

    @Test func subscription_emittingNewWidget_appendsRow() async throws {
        let doc = makeDoc(targets: [.object(id: "obj-a", layout: .basic)])
        let model = makeModel(personalDoc: doc)
        #expect(model.rows.count == 1)

        let task = Task { await model.startSubscriptions() }
        defer { task.cancel() }

        appendObject(to: doc, id: "obj-b", layout: .basic, suffix: "1")
        doc.simulateUpdate([.general])
        try await waitForRows(count: 2, on: model)

        #expect(model.rows.map(\.details.id) == ["obj-a", "obj-b"])
    }

    @Test func subscription_sameStructure_keepsOptimisticReorder() async throws {
        // Simulates: user drags row A below row B (optimistic) and the doc then re-emits
        // an unchanged structure. The dedup compares against `sourceIds` (persisted-order
        // snapshot), not `rows` — so an unchanged-source emission must NOT snap rows back.
        let doc = makeDoc(targets: [
            .object(id: "obj-a", layout: .basic),
            .object(id: "obj-b", layout: .basic)
        ])
        let model = makeModel(personalDoc: doc)

        let task = Task { await model.startSubscriptions() }
        defer { task.cancel() }

        // Direct mutation models the optimistic state independent of `Array.move` semantics.
        model.rows = [model.rows[1], model.rows[0]]
        #expect(model.rows.map(\.details.id) == ["obj-b", "obj-a"])

        doc.simulateUpdate([.general])
        try await Task.sleep(nanoseconds: 20_000_000)

        #expect(model.rows.map(\.details.id) == ["obj-b", "obj-a"])
    }

    // MARK: - Helpers

    private enum WidgetTarget {
        case object(id: String, layout: DetailsLayout?, isDeleted: Bool = false, isArchived: Bool = false)
        case library(id: String)
    }

    private func makeModel(personalDoc: MockBaseDocument) -> MyFavoritesListViewModel {
        MyFavoritesListViewModel(
            spaceId: "space-1",
            personalWidgetsObject: personalDoc,
            channelWidgetsObject: MockBaseDocument(objectId: "channel-doc"),
            onObjectSelected: { _ in }
        )
    }

    private func makeDoc(targets: [WidgetTarget]) -> MockBaseDocument {
        let doc = MockBaseDocument(objectId: "personal-widgets-doc")
        let infoContainer = doc.mockInfoContainer as! InfoContainerMock

        for (index, target) in targets.enumerated() {
            let suffix = "\(index)"
            let (widgetBlock, linkBlock, targetId) = makeWidgetAndLink(target: target, suffix: suffix)
            doc.mockChildren.append(widgetBlock)
            infoContainer.getReturnInfo[linkBlock.id] = linkBlock
            if case let .object(_, layout, isDeleted, isArchived) = target {
                doc.mockDetailsStorage.add(details: makeDetails(
                    id: targetId,
                    layout: layout,
                    isDeleted: isDeleted,
                    isArchived: isArchived
                ))
            }
        }

        return doc
    }

    private func appendObject(to doc: MockBaseDocument, id: String, layout: DetailsLayout, suffix: String) {
        let infoContainer = doc.mockInfoContainer as! InfoContainerMock
        let (widgetBlock, linkBlock, _) = makeWidgetAndLink(target: .object(id: id, layout: layout), suffix: suffix)
        doc.mockChildren.append(widgetBlock)
        infoContainer.getReturnInfo[linkBlock.id] = linkBlock
        doc.mockDetailsStorage.add(details: makeDetails(id: id, layout: layout, isDeleted: false, isArchived: false))
    }

    private func makeWidgetAndLink(target: WidgetTarget, suffix: String) -> (BlockInformation, BlockInformation, String) {
        let widgetId = "widget-\(suffix)"
        let linkId = "link-\(suffix)"
        let targetId: String = {
            switch target {
            case let .object(id, _, _, _): return id
            case let .library(id): return id
            }
        }()

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

        return (widgetBlock, linkBlock, targetId)
    }

    private func makeDetails(
        id: String,
        layout: DetailsLayout?,
        isDeleted: Bool,
        isArchived: Bool
    ) -> ObjectDetails {
        var values: [String: Google_Protobuf_Value] = [:]
        if let layout {
            values[BundledPropertyKey.resolvedLayout.rawValue] = layout.rawValue.protobufValue
        }
        if isDeleted {
            values[BundledPropertyKey.isDeleted.rawValue] = true.protobufValue
        }
        if isArchived {
            values[BundledPropertyKey.isArchived.rawValue] = true.protobufValue
        }
        return ObjectDetails(id: id, values: values)
    }

    private func waitForRows(count expected: Int, on model: MyFavoritesListViewModel, timeoutMs: Int = 1000) async throws {
        let stepNs: UInt64 = 5_000_000
        let maxIterations = (timeoutMs * 1_000_000) / Int(stepNs)
        for _ in 0..<maxIterations {
            if model.rows.count == expected { return }
            try await Task.sleep(nanoseconds: stepNs)
        }
        #expect(model.rows.count == expected, "Timed out waiting for rows.count == \(expected); got \(model.rows.count)")
    }
}
