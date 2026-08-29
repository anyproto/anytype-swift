import SwiftUI
import UIKit

// UIKit-backed search field: SwiftUI cannot observe backspace on an empty field,
// which drives token selection/removal
struct UnifiedSearchTextField: UIViewRepresentable {

    let placeholder: String
    // Bumped by the model to summon the keyboard (a selected token needs it)
    let focusRequestId: Int
    @Binding var text: String
    let onBackspaceWhenEmpty: () -> Void
    let onSubmit: () -> Void

    func makeUIView(context: Context) -> BackspaceObservingTextField {
        let field = BackspaceObservingTextField()
        field.font = UIKitFontBuilder.uiKitFont(font: .uxBodyRegular)
        field.textColor = UIColor.Text.primary
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .go
        // Fill the remaining bar width and yield it back before token pills compress,
        // but never stretch vertically beyond the intrinsic text height
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.setContentHuggingPriority(.required, for: .vertical)
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        field.delegate = context.coordinator
        field.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return field
    }

    func updateUIView(_ field: BackspaceObservingTextField, context: Context) {
        if field.text != text {
            field.text = text
        }
        field.placeholder = placeholder
        context.coordinator.parent = self
        field.onBackspaceWhenEmpty = onBackspaceWhenEmpty
        if context.coordinator.lastFocusRequestId != focusRequestId {
            context.coordinator.lastFocusRequestId = focusRequestId
            if !field.isFirstResponder {
                field.becomeFirstResponder()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: UnifiedSearchTextField
        var lastFocusRequestId = 0

        init(parent: UnifiedSearchTextField) {
            self.parent = parent
        }

        @objc func textChanged(_ field: UITextField) {
            parent.text = field.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.onSubmit()
            return true
        }
    }
}

final class BackspaceObservingTextField: UITextField {

    var onBackspaceWhenEmpty: (() -> Void)?

    private var didAutofocus = false

    // Focus as soon as the field is on screen - the keyboard rises together
    // with the appearing overlay
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil, !didAutofocus else { return }
        didAutofocus = true
        DispatchQueue.main.async { [weak self] in
            self?.becomeFirstResponder()
        }
    }

    override func deleteBackward() {
        let wasEmpty = (text ?? "").isEmpty
        super.deleteBackward()
        if wasEmpty {
            onBackspaceWhenEmpty?()
        }
    }
}
