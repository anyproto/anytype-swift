import Foundation
import Services
import Combine

@MainActor
final class SetTextViewModel: ObservableObject {
    let title: String
    @Published var text = "" {
        didSet {
            onTextChanged(text)
        }
    }
    private let onTextChanged: (String) -> Void
    
    init(title: String, text: String, onTextChanged: @escaping (String) -> Void) {
        self.title = title
        self.text = text
        self.onTextChanged = onTextChanged
    }
}
