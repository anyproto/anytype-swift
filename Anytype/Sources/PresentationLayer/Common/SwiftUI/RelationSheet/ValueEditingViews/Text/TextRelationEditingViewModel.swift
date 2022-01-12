import Foundation
import BlocksModels
import SwiftUI

final class TextRelationEditingViewModel: ObservableObject {
    
    var dismissHandler: (() -> Void)?
    
    @Published var isPresented: Bool = false {
        didSet {
            guard isPresented == false else { return }
            
            saveValue()
        }
    }
    
    @Published var value: String = ""
    
    let title: String
    
    private let type: TextRelationEditingViewType
    private let relationKey: String
    private let service: RelationsServiceProtocol
    
    init(
        type: TextRelationEditingViewType,
        title: String,
        value: String,
        relationKey: String,
        service: RelationsServiceProtocol
    ) {
        self.title = title
        self.value = value
        
        self.type = type
        self.relationKey = relationKey
        self.service = service
    }
    
}

extension TextRelationEditingViewModel {
    
    var keyboardType: UIKeyboardType {
        switch type {
        case .text: return .default
        case .number: return .decimalPad
        }
    }
    
    var placeholder: String {
        switch type {
        case .text: return "Add text".localized
        case .number: return "Add number".localized
        }
    }
    
}

extension TextRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        switch type {
        case .text:
            service.updateRelation(relationKey: relationKey, value: value.protobufValue)
        case .number:
            let filterredString = value.components(
                separatedBy:CharacterSet(charactersIn: "0123456789.").inverted
            )
                .joined()
            
            guard let number = Double(filterredString) else { return }
            service.updateRelation(relationKey: relationKey, value: number.protobufValue)
        }
    }
    
    func makeView() -> AnyView {
        AnyView(TextRelationEditingView(viewModel: self))
    }
    
}
