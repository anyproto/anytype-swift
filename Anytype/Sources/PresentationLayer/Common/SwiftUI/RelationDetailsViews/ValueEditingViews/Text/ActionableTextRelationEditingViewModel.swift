import Foundation
import BlocksModels
import SwiftUI

final class ActionableTextRelationEditingViewModel: ObservableObject {
    
    var onDismiss: () -> Void = {}
    
    @Published var isPresented: Bool = false {
        didSet {
            guard isPresented == false else { return }
            
            saveValue()
        }
    }
    
    @Published var value: String = "" {
        didSet {
            updateActionButtonState()
        }
    }
    
    @Published var isActionButtonEnabled: Bool = false
   
    let title: String
    
    private let type: ActionableTextRelationEditingViewType
    private let relationKey: String

    private let service: RelationsServiceProtocol
    private weak var delegate: TextRelationEditingViewModelDelegate?
    
    init(
        type: ActionableTextRelationEditingViewType,
        value: String,
        title: String,
        relationKey: String,
        service: RelationsServiceProtocol,
        delegate: TextRelationEditingViewModelDelegate?
    ) {
        self.value = value
        self.title = title
        
        self.type = type
        self.relationKey = relationKey
        self.service = service
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

extension ActionableTextRelationEditingViewModel {
    
    var keyboardType: UIKeyboardType { type.keyboardType }
    var placeholder: String { type.placeholder }
//    var icon: Image { type.icon }
    
}

extension ActionableTextRelationEditingViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        let value = value.replacingOccurrences(of: " ", with: "")
        service.updateRelation(relationKey: relationKey, value: value.protobufValue)
    }
    
    func makeView() -> AnyView {
        AnyView(ActionableTextRelationEditingView(viewModel: self))
    }
    
}

private extension ActionableTextRelationEditingViewModel {
    
    func updateActionButtonState() {
        guard value.isNotEmpty else {
            isActionButtonEnabled = false
            return
        }

        switch type {
        case .phone:
            isActionButtonEnabled = value.isValidPhone()
        case .email:
            isActionButtonEnabled = value.isValidEmail()
        case .url:
            isActionButtonEnabled = value.isValidURL()
        }
    }
    
    var urlToOpen: URL? {
        switch type {
        case .phone: return URL(string: "tel:\(value)")
        case .email: return URL(string: "mailto:\(value)")
        case .url: return URL(string: value)
        }
    }
    
}

// MARK: - `ActionableTextRelationEditingViewType` extentions

private extension ActionableTextRelationEditingViewType {
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .phone: return .phonePad
        case .email: return .emailAddress
        case .url: return .URL
        }
    }
    
    var placeholder: String {
        switch self {
        case .phone: return "Add phone number".localized
        case .email: return "Add email".localized
        case .url: return "Add URL".localized
        }
    }
    
//    var icon: Image {
//        switch self {
//        case .phone: return Image.Relations.Icons.Small.phone
//        case .email: return Image.Relations.Icons.Small.email
//        case .url: return Image.Relations.Icons.Small.goToURL
//        }
//    }
    
}
