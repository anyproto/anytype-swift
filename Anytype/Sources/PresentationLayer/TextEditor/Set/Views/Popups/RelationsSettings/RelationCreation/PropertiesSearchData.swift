import SwiftUI
import Services

struct PropertiesSearchData: Identifiable {
    let id = UUID()
    let objectId: String
    let spaceId: String
    let excludedRelationsIds: [String]
    let target: PropertiesModuleTarget
    @EquatableNoop
    var onRelationSelect: (_ relationDetails: RelationDetails, _ isNew: Bool) -> Void
}
