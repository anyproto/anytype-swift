import SwiftUI

struct RelationFormatsData: Identifiable {
    let id = UUID()
    let format: SupportedRelationFormat
    let onSelect: (SupportedRelationFormat) -> Void
}
