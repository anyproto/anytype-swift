import Foundation
import SwiftUI
import BlocksModels

final class NewRelationViewModel: ObservableObject {
    
    @Published var name: String
    @Published private(set) var format: SupportedRelationFormat = .text
    
    init(name: String) {
        self.name = name
    }
    
}

extension NewRelationViewModel {
    
    func didTapFormatSection() {
        
    }
    
}
