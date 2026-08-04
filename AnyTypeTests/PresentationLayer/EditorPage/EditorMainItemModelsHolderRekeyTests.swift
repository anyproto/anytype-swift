import Testing
import UIKit
import Services
@testable import Anytype

// Covers the mapping re-key the identity-swap rebind relies on: after a live model's block id
// changes in place, updateMappings must key the same instance under the new id so the
// builder's cache lookup returns it instead of building a duplicate row.
struct EditorMainItemModelsHolderRekeyTests {

    @MainActor
    @Test func updateMappingsRekeysReboundModel() {
        let model = StubBlockViewModel(info: makeInfo(id: "old"))
        let holder = EditorMainItemModelsHolder()
        holder.items = [.block(model)]
        #expect(holder.blocksMapping["old"] as AnyObject === model)

        model.info = makeInfo(id: "new")
        holder.updateMappings()

        #expect(holder.blocksMapping["new"] as AnyObject === model)
        #expect(holder.blocksMapping["old"] == nil)
    }

    private func makeInfo(id: String) -> BlockInformation {
        .empty(id: id, content: .text(.empty(contentType: .text)))
    }
}

private final class StubBlockViewModel: BlockViewModelProtocol {
    var info: BlockInformation
    let className = "StubBlockViewModel"

    init(info: BlockInformation) {
        self.info = info
    }

    @MainActor
    func makeContentConfiguration(maxWidth: CGFloat) -> any UIContentConfiguration {
        UIListContentConfiguration.cell()
    }

    @MainActor
    func didSelectRowInTableView(editorEditingState: EditorEditingState) {}
}
