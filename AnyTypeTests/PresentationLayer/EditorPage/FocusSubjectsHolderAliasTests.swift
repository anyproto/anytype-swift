import Testing
import Combine
import Services
@testable import Anytype

struct FocusSubjectsHolderAliasTests {

    @Test func aliasRoutesNewIdToOldSubject() {
        let holder = FocusSubjectsHolder()
        let oldSubject = holder.focusSubject(for: "old")
        holder.alias(oldId: "old", newId: "new")
        #expect(holder.focusSubject(for: "new") === oldSubject)
    }

    @Test func aliasDoesNotOverwriteExistingSubject() {
        let holder = FocusSubjectsHolder()
        let existingSubject = holder.focusSubject(for: "new")
        holder.alias(oldId: "old", newId: "new")
        #expect(holder.focusSubject(for: "new") === existingSubject)
    }

    @Test func removeAliasRemovesTheAliasedEntry() {
        let holder = FocusSubjectsHolder()
        holder.alias(oldId: "old", newId: "new")
        holder.removeAlias(oldId: "old", newId: "new")
        // A fresh subject gets created after removal — the aliased instance is gone.
        #expect(holder.focusSubject(for: "new") !== holder.focusSubject(for: "old"))
    }

    @Test func removeAliasKeepsIndependentlyCreatedSubject() {
        let holder = FocusSubjectsHolder()
        let independent = holder.focusSubject(for: "new")
        _ = holder.focusSubject(for: "old")
        holder.removeAlias(oldId: "old", newId: "new")
        #expect(holder.focusSubject(for: "new") === independent)
    }
}
