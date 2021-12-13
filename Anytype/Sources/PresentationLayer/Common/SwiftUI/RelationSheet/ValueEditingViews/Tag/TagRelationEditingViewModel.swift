import Foundation
import SwiftUI

final class TagRelationEditingViewModel: ObservableObject {
    
    var onDismiss: (() -> Void)?
    
    @Published var selectedTags: [Relation.Tag.Option]
    
    let relationName: String
    
    private let relationKey: String
    private let allTags: [Relation.Tag.Option]
    
    private let detailsService: DetailsServiceProtocol
    private let relationsService: RelationsServiceProtocol
    
    init(
        relationTag: Relation.Tag,
        detailsService: DetailsServiceProtocol,
        relationsService: RelationsServiceProtocol
    ) {
        self.selectedTags = relationTag.selectedTags
        self.relationName = relationTag.name
        self.relationKey = relationTag.id
        self.allTags = relationTag.allTags

        self.detailsService = detailsService
        self.relationsService = relationsService
    }
    
}

extension TagRelationEditingViewModel: RelationEditingViewModelProtocol {
  
    func makeView() -> AnyView {
        AnyView(TagRelationEditingView(viewModel: self))
    }
    
}
