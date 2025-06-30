import Foundation
import Services

extension SearchObjectRowView.Model {
    
    init(relationDetails: PropertyDetails) {
        self.id = relationDetails.id
        self.icon = .asset(relationDetails.format.iconAsset)
        self.title = relationDetails.name
        self.subtitle = nil
        self.style = .compact
        self.isChecked = false
    }
    
}
