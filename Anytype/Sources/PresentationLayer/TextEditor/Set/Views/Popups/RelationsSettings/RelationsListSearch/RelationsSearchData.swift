import SwiftUI
import Services

struct RelationsSearchData: Identifiable {
    let id = UUID()
    let document: BaseDocumentProtocol
    let excludedRelationsIds: [String]
    let target: RelationsModuleTarget
    @EquatableNoop
    var onRelationSelect: (_ relationDetails: RelationDetails, _ isNew: Bool) -> Void
}
