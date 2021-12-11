import SwiftUI

class FlowRelationsViewModel: ObservableObject {
    @Published var relations: [NewRelation]
    @Published var alignment: HorizontalAlignment = .leading
    let onRelationTap: (NewRelation) -> Void

    init(relations: [NewRelation], onRelationTap: @escaping (NewRelation) -> Void) {
        self.relations = relations
        self.onRelationTap = onRelationTap
    }
}
