import Foundation
import BlocksModels
import SwiftUI

final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var isPresented: Bool = false
    
    @Published var value: String = "" {
        didSet {
            updateActionButtonState()
        }
    }
    
    @Published var isActionButtonEnabled: Bool = false
    
    var onDismiss: (() -> Void)?
    
    let valueType: TextRelationValueType
    
    let relationName: String
    
    private let relationKey: String

    private let service: TextRelationEditingServiceProtocol
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(
        relationKey: String,
        relationName: String,
        relationValue: String?,
        service: TextRelationEditingServiceProtocol,
        delegate: TextRelationEditingViewModelDelegate?
    ) {
        self.relationKey = relationKey
        self.relationName = relationName
        self.value = relationValue ?? ""
        
        self.service = service
        self.valueType = service.valueType
        
        self.delegate = delegate
        
        updateActionButtonState()
    }
    
    func performAction() {
        guard
            let url = urlToOpen,
            let delegate = delegate,
            delegate.canOpenUrl(url)
        else { return }
        
        delegate.openUrl(url)
    }
    
}

extension TextRelationEditingViewModel: RelationEditingViewModelProtocol2 {
    
}

extension TextRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func viewWillDisappear() {
        saveValue()
    }
    
    func saveValue() {
        service.save(value: value, forKey: relationKey)
    }
    
    func makeView() -> AnyView {
        AnyView(TextRelationEditingView(viewModel: self))
    }
    
}

private extension TextRelationEditingViewModel {
    
    func updateActionButtonState() {
        guard value.isNotEmpty else {
            isActionButtonEnabled = false
            return
        }
        
        switch valueType {
        case .text: return
        case .number: return
        case .phone:
            isActionButtonEnabled = value.isValidPhone()
        case .email:
            isActionButtonEnabled = value.isValidEmail()
        case .url:
            isActionButtonEnabled = value.isValidURL()
        }
    }
    
    var urlToOpen: URL? {
        switch valueType {
        case .text: return nil
        case .number: return nil
        case .phone: return URL(string: "tel:\(value)")
        case .email: return URL(string: "mailto:\(value)")
        case .url: return URL(string: value)
        }
    }
    
}
