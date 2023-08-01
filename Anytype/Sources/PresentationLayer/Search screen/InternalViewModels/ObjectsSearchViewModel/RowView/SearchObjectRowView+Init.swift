import Foundation
import Services

extension SearchObjectRowView.Model {
    
    init(relationDetails: RelationDetails) {
        self.icon = .asset(relationDetails.format.iconAsset)
        self.title = relationDetails.name
        self.subtitle = nil
        self.style = .compact
        self.isChecked = false
    }
    
}
