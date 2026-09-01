import Testing
@testable import Anytype

struct UnifiedSearchStateTests {

    @Test
    func addingSpaceScopeConvertsTypeFocusIntoTypeFilter() {
        var state = UnifiedSearchState(tokens: [.typeFocus(uniqueKey: "task")])

        state.setSpaceScope("space-1")

        #expect(state.tokens == [
            .type(uniqueKey: "task"),
            .space(spaceId: "space-1")
        ])
        #expect(state.focusedTypeKey == nil)
        #expect(state.typeUniqueKey == "task")
        #expect(state.spaceScopeId == "space-1")
    }
}
