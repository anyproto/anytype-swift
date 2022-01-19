import Foundation
import BlocksModels
import SwiftUI

final class TextRelationDetailsViewModel: ObservableObject {
    
    var onDismiss: () -> Void = {}
    
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
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
    }()
    
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

extension TextRelationDetailsViewModel {
    
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

extension TextRelationDetailsViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        switch type {
        case .text:
            service.updateRelation(relationKey: relationKey, value: value.protobufValue)
        case .number:
            guard let number = numberFormatter.number(from: value)?.doubleValue else { return }
            service.updateRelation(relationKey: relationKey, value: number.protobufValue)
        }
    }
    
    func makeView() -> AnyView {
        AnyView(TextRelationDetailsView(viewModel: self))
    }
    
}
