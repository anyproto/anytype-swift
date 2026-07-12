import Testing
import Foundation
@testable import Anytype
import Services
import SwiftProtobuf
import ProtobufMessages
import AnytypeCore

@Suite
struct SetKanbanCardMoveTests {

    // MARK: - Tag: read-modify-write

    @Test func testTagMove_PreservesOtherTags() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a", "b"],
            sourceGroupValue: .tag(ids: ["a"]),
            targetGroupValue: .tag(ids: ["c"]),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["b", "c"])))
    }

    @Test func testTagMove_FromCombinationColumn_RemovesAllSourceIds() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a", "b", "c"],
            sourceGroupValue: .tag(ids: ["a", "b"]),
            targetGroupValue: .tag(ids: ["d"]),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["c", "d"])))
    }

    @Test func testTagMove_ToCombinationColumn_AddsAllTargetIds() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a"],
            sourceGroupValue: .tag(ids: ["a"]),
            targetGroupValue: .tag(ids: ["b", "c"]),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["b", "c"])))
    }

    @Test func testTagMove_ToNoValueColumn_RemovesOnlySourceIds() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a", "b"],
            sourceGroupValue: .tag(ids: ["a"]),
            targetGroupValue: .tag(ids: []),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["b"])))
    }

    @Test func testTagMove_FromNoValueColumn_AddsTargetIds() {
        let result = SetKanbanCardMove.compute(
            currentValue: [],
            sourceGroupValue: .tag(ids: []),
            targetGroupValue: .tag(ids: ["c"]),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["c"])))
    }

    @Test func testTagMove_TargetAlreadyPresent_NoDuplicates() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a", "c"],
            sourceGroupValue: .tag(ids: ["a"]),
            targetGroupValue: .tag(ids: ["c"]),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["c"])))
    }

    @Test func testTagMove_NoEffectiveChange_Ignored() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["c"],
            sourceGroupValue: .tag(ids: []),
            targetGroupValue: .tag(ids: ["c"]),
            groupsLoaded: true
        )

        #expect(result == .ignore)
    }

    @Test func testTagMove_UnresolvedSource_AddsWithoutRemoving() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a", "b"],
            sourceGroupValue: nil,
            targetGroupValue: .tag(ids: ["c"]),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["a", "b", "c"])))
    }

    @Test func testTagMove_UnresolvedSourceToNoValue_Ignored() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a", "b"],
            sourceGroupValue: nil,
            targetGroupValue: .tag(ids: []),
            groupsLoaded: true
        )

        #expect(result == .ignore)
    }

    @Test func testTagMove_UnresolvedSourceAndUnreadableCurrentValue_Ignored() {
        let result = SetKanbanCardMove.compute(
            currentValue: [],
            sourceGroupValue: nil,
            targetGroupValue: .tag(ids: ["c"]),
            groupsLoaded: true
        )

        #expect(result == .ignore)
    }

    // MARK: - Status: single-value replace

    @Test func testStatusMove_ReplacesValue() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["old"],
            sourceGroupValue: .status(id: "old"),
            targetGroupValue: .status(id: "new"),
            groupsLoaded: true
        )

        #expect(result == .write(.ids(["new"])))
    }

    @Test func testStatusMove_ToNoValueColumn_Unsets() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["old"],
            sourceGroupValue: .status(id: "old"),
            targetGroupValue: .status(id: ""),
            groupsLoaded: true
        )

        #expect(result == .write(.unset))
    }

    // MARK: - Checkbox

    @Test func testCheckboxMove_WritesTargetChecked() {
        let result = SetKanbanCardMove.compute(
            currentValue: [],
            sourceGroupValue: .checkbox(checked: false),
            targetGroupValue: .checkbox(checked: true),
            groupsLoaded: true
        )

        #expect(result == .write(.checked(true)))
    }

    @Test func testCheckboxMove_WritesTargetUnchecked() {
        let result = SetKanbanCardMove.compute(
            currentValue: [],
            sourceGroupValue: .checkbox(checked: true),
            targetGroupValue: .checkbox(checked: false),
            groupsLoaded: true
        )

        #expect(result == .write(.checked(false)))
    }

    // MARK: - Guards

    @Test func testMove_GroupsNotLoaded_Ignored() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a"],
            sourceGroupValue: .tag(ids: ["a"]),
            targetGroupValue: .tag(ids: ["c"]),
            groupsLoaded: false
        )

        #expect(result == .ignore)
    }

    @Test func testMove_UnresolvedTarget_Ignored() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a"],
            sourceGroupValue: .tag(ids: ["a"]),
            targetGroupValue: nil,
            groupsLoaded: true
        )

        #expect(result == .ignore)
    }

    @Test func testMove_DateTarget_Ignored() {
        let result = SetKanbanCardMove.compute(
            currentValue: ["a"],
            sourceGroupValue: nil,
            targetGroupValue: .date(Anytype_Model_Block.Content.Dataview.Date()),
            groupsLoaded: true
        )

        #expect(result == .ignore)
    }

    // MARK: - Per-column create prefill

    @Test func testPrefill_StatusColumn() {
        let value = SetKanbanCardMove.prefilledValue(targetGroupValue: .status(id: "s1"))
        #expect(value == ["s1"].protobufValue)
    }

    @Test func testPrefill_TagCombinationColumn() {
        let value = SetKanbanCardMove.prefilledValue(targetGroupValue: .tag(ids: ["a", "b"]))
        #expect(value == ["a", "b"].protobufValue)
    }

    @Test func testPrefill_CheckboxColumn() {
        let value = SetKanbanCardMove.prefilledValue(targetGroupValue: .checkbox(checked: true))
        #expect(value == true.protobufValue)
    }

    @Test func testPrefill_NoValueColumns_Nil() {
        #expect(SetKanbanCardMove.prefilledValue(targetGroupValue: .tag(ids: [])) == nil)
        #expect(SetKanbanCardMove.prefilledValue(targetGroupValue: .status(id: "")) == nil)
        #expect(SetKanbanCardMove.prefilledValue(targetGroupValue: nil) == nil)
    }

    // MARK: - Current value parsing (scalar or list)

    @Test func testStringList_ListValue() {
        let value = ["a", "b"].protobufValue
        #expect(SetKanbanCardMove.stringList(from: value) == ["a", "b"])
    }

    @Test func testStringList_ScalarValue() {
        let value = "a".protobufValue
        #expect(SetKanbanCardMove.stringList(from: value) == ["a"])
    }

    @Test func testStringList_NilOrEmpty() {
        #expect(SetKanbanCardMove.stringList(from: nil) == [])
        #expect(SetKanbanCardMove.stringList(from: Google_Protobuf_Value(nilLiteral: ())) == [])
        #expect(SetKanbanCardMove.stringList(from: "".protobufValue) == [])
    }
}

private extension DataviewGroupValue {
    static func tag(ids: [String]) -> DataviewGroupValue {
        .tag(.with { $0.ids = ids })
    }

    static func status(id: String) -> DataviewGroupValue {
        .status(.with { $0.id = id })
    }

    static func checkbox(checked: Bool) -> DataviewGroupValue {
        .checkbox(.with { $0.checked = checked })
    }
}
