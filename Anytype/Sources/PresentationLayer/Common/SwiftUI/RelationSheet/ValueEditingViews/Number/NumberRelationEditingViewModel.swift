import Foundation
import BlocksModels
import SwiftUI

final class NumberRelationEditingViewModel: ObservableObject {
    
    @Published var value: String = ""
    
    private let relationKey: String
    private let service: DetailsService
    
    init(objectId: BlockId, relationKey: String, value: String?) {
        self.service = DetailsService(objectId: objectId)
        self.relationKey = relationKey
        self.value = value ?? ""
    }
    
}

extension NumberRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        let filterredString = value.components(
            separatedBy:CharacterSet(charactersIn: "0123456789.").inverted
        )
            .joined()
        
        guard let number = Double(filterredString) else { return }
        service.updateDetails([DetailsUpdate(key: relationKey, value: number.protobufValue)])
    }
    
    func makeView() -> AnyView {
        AnyView(NumberRelationEditingView(viewModel: self))
    }
    
}
