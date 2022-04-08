import Foundation
import SwiftUI
import BlocksModels

final class NewRelationViewModel: ObservableObject {
    
    @Published var name: String
    @Published private(set) var format: SupportedRelationFormat = .text
    
    private weak var output: NewRelationModuleOutput?
    
    init(name: String, output: NewRelationModuleOutput?) {
        self.name = name
        self.output = output
    }
    
}

extension NewRelationViewModel {
    
    func didTapFormatSection() {
        output?.didAskToShowRelationFormats()
    }
    
}

extension NewRelationViewModel: NewRelationModuleInput {
    
    func updateRelationFormat(_ newFormat: SupportedRelationFormat) {
        format = newFormat
    }
    
}
