import Foundation
import Services

extension SearchObjectRowView.Model {
    
    init(relationDetails: RelationDetails) {
        self.icon = .imageAsset(relationDetails.format.iconAsset)
        self.title = relationDetails.name
        self.subtitle = nil
        self.style = .compact
        self.isChecked = false
    }
    
}
