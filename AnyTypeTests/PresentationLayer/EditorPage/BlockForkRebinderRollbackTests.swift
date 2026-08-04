import Testing
@testable import Anytype
import Services

// Covers rollbackFailedFork's no-live-row paths — the model-present rebind-back path needs
// the TextBlockViewModel construction stack and is exercised on device instead.
@MainActor
struct BlockForkRebinderRollbackTests {

    private final class InfoContainerStub: InfoContainerProtocol, @unchecked Sendable {
        var infos = [String: BlockInformation]()
        func get(id: String) -> BlockInformation? { infos[id] }
        func add(_ info: BlockInformation) { infos[info.id] = info }
        func remove(id: String) { infos.removeValue(forKey: id) }
        func children(of id: String) -> [BlockInformation] { [] }
        func recursiveChildren(of id: String) -> [BlockInformation] { [] }
        func setChildren(ids: [String], parentId: String) { }
        func update(blockId: String, update: (BlockInformation) -> (BlockInformation?)) { }
    }

    private func makeRebinder(
        map: BlockRowIdentityMap,
        container: InfoContainerStub,
        focusSubjectHolder: FocusSubjectsHolder,
        cursorManager: EditorCursorManager
    ) -> BlockForkRebinder {
        BlockForkRebinder(
            modelsHolder: EditorMainItemModelsHolder(),
            rowIdentityMap: map,
            infoContainer: container,
            focusSubjectHolder: focusSubjectHolder,
            cursorManager: cursorManager,
            collectionController: EditorBlockCollectionController(viewInput: nil)
        )
    }

    @Test func rollbackWithoutLiveRowFreesAliasAndFabricatedInfo() {
        let map = BlockRowIdentityMap()
        let container = InfoContainerStub()
        let focusSubjectHolder = FocusSubjectsHolder()
        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let rebinder = makeRebinder(map: map, container: container, focusSubjectHolder: focusSubjectHolder, cursorManager: cursorManager)

        #expect(map.register(newBlockId: "b", replacing: "a"))
        container.add(.empty(id: "b", content: .text(.empty(contentType: .text))))

        rebinder.rollbackFailedFork(replacementId: "b", oldId: "a")

        // The alias and the fabricated info are gone; both id roles are free for a fresh fork.
        #expect(map.latestId(for: "a") == "a")
        #expect(container.get(id: "b") == nil)
        #expect(map.register(newBlockId: "c", replacing: "a"))
    }

    @Test func rollbackWithoutPriorRebindKeepsForeignFocusSubject() {
        let map = BlockRowIdentityMap()
        let container = InfoContainerStub()
        let focusSubjectHolder = FocusSubjectsHolder()
        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let rebinder = makeRebinder(map: map, container: container, focusSubjectHolder: focusSubjectHolder, cursorManager: cursorManager)

        // The fallback fork path (rebind declined): no alias, but a subject may exist under
        // the replacement id from the pending-focus fallback. Rolling back must not move it
        // over the old id's legitimate subject.
        let oldSubject = focusSubjectHolder.focusSubject(for: "a")
        _ = focusSubjectHolder.focusSubject(for: "b")

        rebinder.rollbackFailedFork(replacementId: "b", oldId: "a")

        #expect(focusSubjectHolder.focusSubject(for: "a") === oldSubject)
    }

    @Test func rollbackClearsPendingFocusForReplacementId() {
        let map = BlockRowIdentityMap()
        let container = InfoContainerStub()
        let focusSubjectHolder = FocusSubjectsHolder()
        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let rebinder = makeRebinder(map: map, container: container, focusSubjectHolder: focusSubjectHolder, cursorManager: cursorManager)

        cursorManager.blockFocus = BlockFocus(id: "b", position: .beginning)
        rebinder.rollbackFailedFork(replacementId: "b", oldId: "a")
        #expect(cursorManager.blockFocus == nil)

        // A pending focus for an unrelated block survives.
        cursorManager.blockFocus = BlockFocus(id: "x", position: .beginning)
        rebinder.rollbackFailedFork(replacementId: "b", oldId: "a")
        #expect(cursorManager.blockFocus?.id == "x")
    }
}
