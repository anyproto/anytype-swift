import Foundation
import BlocksModels
import SwiftUI

final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var value: String = "" {
        didSet {
            updateActionButtonState()
        }
    }
    
    @Published var isActionButtonEnabled: Bool = false
    
    let valueType: TextRelationValueType
    
    private let service: TextRelationEditingServiceProtocol
    private let key: String
    
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(
        service: TextRelationEditingServiceProtocol,
        key: String,
        value: String?,
        delegate: TextRelationEditingViewModelDelegate?
    ) {
        self.service = service
        self.key = key
        self.value = value ?? ""
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

extension TextRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func viewWillDisappear() {
        saveValue()
    }
    
    func saveValue() {
        service.save(value: value, forKey: key)
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
