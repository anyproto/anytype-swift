import SwiftUI
import Services

struct RelationsSearchData: Identifiable {
    let id = UUID()
    let document: BaseDocumentProtocol
    let excludedRelationsIds: [String]
    let target: RelationsModuleTarget
}
