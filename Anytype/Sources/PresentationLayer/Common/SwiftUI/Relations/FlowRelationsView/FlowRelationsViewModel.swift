import SwiftUI

class FlowRelationsViewModel: ObservableObject {
    @Published var relations: [Relation]
    @Published var alignment: HorizontalAlignment = .leading
    let onRelationTap: (Relation) -> Void

    init(relations: [Relation], onRelationTap: @escaping (Relation) -> Void) {
        self.relations = relations
        self.onRelationTap = onRelationTap
    }
}
