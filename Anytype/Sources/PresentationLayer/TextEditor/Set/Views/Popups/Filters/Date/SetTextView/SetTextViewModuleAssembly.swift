import SwiftUI

protocol SetTextViewModuleAssemblyProtocol {
    @MainActor
    func make(title: String, text: String, onTextChanged: @escaping (String) -> Void) -> AnyView
}

final class SetTextViewModuleAssembly: SetTextViewModuleAssemblyProtocol {
    
    // MARK: - SetTextViewModuleAssemblyProtocol
    
    @MainActor
    func make(title: String, text: String, onTextChanged: @escaping (String) -> Void) -> AnyView {
        return SetTextView(
            model: SetTextViewModel(
                title: title,
                text: text,
                onTextChanged: onTextChanged
            )
        ).eraseToAnyView()
    }
}
