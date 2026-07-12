import Testing
import Foundation
@testable import Anytype
import Services
import SwiftProtobuf
import ProtobufMessages
import AnytypeCore

@Suite
struct SetKanbanColumnHeaderTests {

    private let options: [String: ObjectDetails] = [
        "opt-a": .mockOption(id: "opt-a", name: "To Do", color: "red"),
        "opt-b": .mockOption(id: "opt-b", name: "Doing", color: "blue")
    ]

    private func header(for group: DataviewGroup) -> SetKanbanColumnHeaderType {
        group.header(checkboxTitle: "Done", optionDetails: { options[$0] })
    }

    @Test func testStatusGroup_ResolvedOption() {
        let group = DataviewGroup.mock(value: .status(.with { $0.id = "opt-a" }))

        guard case let .status(statusOptions) = header(for: group) else {
            Issue.record("Expected status header")
            return
        }
        #expect(statusOptions.count == 1)
        #expect(statusOptions.first?.text == "To Do")
    }

    @Test func testStatusGroup_UnresolvedOption_FallsBackToUncategorized() {
        let group = DataviewGroup.mock(value: .status(.with { $0.id = "deleted-option" }))

        guard case .uncategorized = header(for: group) else {
            Issue.record("Expected uncategorized header, never a raw id")
            return
        }
    }

    @Test func testTagGroup_CombinationColumn_ResolvesAllIds() {
        let group = DataviewGroup.mock(value: .tag(.with { $0.ids = ["opt-a", "opt-b"] }))

        guard case let .tag(tagOptions) = header(for: group) else {
            Issue.record("Expected tag header")
            return
        }
        #expect(tagOptions.map(\.text) == ["To Do", "Doing"])
    }

    @Test func testTagGroup_EmptyIds_Uncategorized() {
        let group = DataviewGroup.mock(value: .tag(.with { $0.ids = [] }))

        guard case .uncategorized = header(for: group) else {
            Issue.record("Expected uncategorized header")
            return
        }
    }

    @Test func testCheckboxGroup_UsesDisplayName() {
        let group = DataviewGroup.mock(value: .checkbox(.with { $0.checked = true }))

        guard case let .checkbox(title, isChecked) = header(for: group) else {
            Issue.record("Expected checkbox header")
            return
        }
        #expect(title == "Done")
        #expect(isChecked == true)
    }

    @Test func testStatusGroup_BackgroundColorFromOption() {
        let group = DataviewGroup.mock(value: .status(.with { $0.id = "opt-a" }))
        let color = group.backgroundColor(optionDetails: { options[$0] })
        #expect(color == MiddlewareColor.red.backgroundColor)
    }

    @Test func testStatusGroup_BackgroundColorUnresolved_Nil() {
        let group = DataviewGroup.mock(value: .status(.with { $0.id = "deleted-option" }))
        let color = group.backgroundColor(optionDetails: { options[$0] })
        #expect(color == nil)
    }
}

private extension DataviewGroup {
    static func mock(value: DataviewGroupValue) -> DataviewGroup {
        DataviewGroup.with {
            $0.id = "group-id"
            $0.value = value
        }
    }
}

private extension ObjectDetails {
    static func mockOption(id: String, name: String, color: String) -> ObjectDetails {
        ObjectDetails(id: id, values: [
            BundledPropertyKey.name.rawValue: name.protobufValue,
            BundledPropertyKey.relationOptionColor.rawValue: color.protobufValue
        ])
    }
}
