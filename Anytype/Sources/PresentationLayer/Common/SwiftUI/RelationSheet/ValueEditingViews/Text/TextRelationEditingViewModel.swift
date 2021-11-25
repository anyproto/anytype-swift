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
    
    init(
        service: TextRelationEditingServiceProtocol,
        key: String,
        value: String?
    ) {
        self.service = service
        self.key = key
        self.value = value ?? ""
        self.valueType = service.valueType
        
        updateActionButtonState()
    }
    
    func performAction() {
        guard value.isNotEmpty else { return }
        
        let sharedApplication = UIApplication.shared

        switch valueType {
        case .text: return
        case .number: return
        case .phone:
            guard
                let url = URL(string: "tel://\(value)"),
                sharedApplication.canOpenURL(url)
            else {
                return
            }
            sharedApplication.open(url)
        case .email:
            guard
                let url = URL(string: "mailto://\(value)"),
                sharedApplication.canOpenURL(url)
            else {
                return
            }
            sharedApplication.open(url)
        case .url:
            guard
                let url = URL(string: value),
                sharedApplication.canOpenURL(url)
            else {
                return
            }
            sharedApplication.open(url)
        }
    }
    
}

extension TextRelationEditingViewModel: RelationEditingViewModelProtocol {
    
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
        
        let sharedApplication = UIApplication.shared

        switch valueType {
        case .text: return
        case .number: return
        case .phone:
            guard let url = URL(string: "tel://\(value)") else {
                self.isActionButtonEnabled = false
                return
            }
            isActionButtonEnabled = sharedApplication.canOpenURL(url)
        case .email:
            guard let url = URL(string: "mailto://\(value)") else {
                self.isActionButtonEnabled = false
                return
            }
            isActionButtonEnabled = sharedApplication.canOpenURL(url)
        case .url:
            guard let url = URL(string: value) else {
                self.isActionButtonEnabled = false
                return
            }
            isActionButtonEnabled = sharedApplication.canOpenURL(url)
        }
    }
    
}
