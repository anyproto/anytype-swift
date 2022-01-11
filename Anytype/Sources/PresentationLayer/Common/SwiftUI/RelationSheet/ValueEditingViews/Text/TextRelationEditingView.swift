import SwiftUI

struct TextRelationEditingView: View {
            
    @ObservedObject var viewModel: TextRelationEditingViewModel
    @State private var height: CGFloat = 0
    
    var body: some View {
        textView
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .modifier(RelationSheetModifier(isPresented: $viewModel.isPresented, title: viewModel.relationName, dismissCallback: viewModel.dismissHandler))
    }
    
    private var textView: some View {
        HStack(spacing: 8) {
            RelationTextView(text: $viewModel.value, placeholder: viewModel.valueType.placeholder, keyboardType: viewModel.valueType.keyboardType)
            
            if let icon = viewModel.valueType.icon, viewModel.value.isNotEmpty, viewModel.isActionButtonEnabled {
                Button {
                    viewModel.performAction()
                } label: {
                    icon
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.grayscale30, lineWidth: 1)
                        )
                }
            }
        }
    }
    
}

// MARK: - `TextRelationValueType` extentions

private extension TextRelationValueType {
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .text: return .default
        case .number: return .decimalPad
        case .phone: return .phonePad
        case .email: return .emailAddress
        case .url: return .URL
        }
    }
    
    var placeholder: String {
        switch self {
        case .text: return "Add text".localized
        case .number: return "Add number".localized
        case .phone: return "Add phone number".localized
        case .email: return "Add email".localized
        case .url: return "Add URL".localized
        }
    }
    
    var icon: Image? {
        switch self {
        case .text: return nil
        case .number: return nil
        case .phone: return Image.Relations.Icons.Small.phone
        case .email: return Image.Relations.Icons.Small.email
        case .url: return Image.Relations.Icons.Small.goToURL
        }
    }
    
}

struct RelationTextValueEditingView_Previews: PreviewProvider {
    static var previews: some View {
        TextRelationEditingView(
            viewModel: TextRelationEditingViewModel(
                relationKey: "key",
                relationName: "name",
                relationValue: "value",
                service: TextRelationEditingService(objectId: "", valueType: .phone),
                delegate: nil
            )
        )
            .background(Color.red)
    }
}
