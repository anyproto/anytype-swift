import Foundation
import SwiftUI
import BlocksModels

final class NewRelationViewModel: ObservableObject {
    
    @Published var name: String
    @Published private(set) var formatModel: NewRelationFormatSectionView.Model
    
    init(name: String = "", format: RelationMetadata.Format = .longText) {
        self.name = name
        self.formatModel = NewRelationFormatSectionView.Model(format: format)
    }
    
}

extension NewRelationViewModel {
    
    func didTapFormatSection() {
        
    }
    
}

private extension NewRelationFormatSectionView.Model {
    
    init(format: RelationMetadata.Format) {
        self.icon = format.iconName
        self.title = format.name
    }
    
}
