import SwiftUI

struct SettingsInfoEditingViewData: Identifiable {
    let title: String
    let placeholder: String
    let initialValue: String
    
    let onSave: (String) -> Void
    
    var id: String { title + placeholder + initialValue }
}

struct SettingsInfoEditingView: View {
    private let title: String
    private let placeholder: String
    private let initialValue: String
    
    private let onSave: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    init(_ data: SettingsInfoEditingViewData) {
        title = data.title
        placeholder = data.placeholder
        initialValue = data.initialValue
        onSave = data.onSave
    }
    
    @State private var value: String = ""
    
    private var haveChanges: Bool { value != initialValue }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            header
            editingView
            Spacer()
        }
        .onAppear {
            value = initialValue
        }
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            Spacer()
            
            Button {
                UISelectionFeedbackGenerator().selectionChanged()
                dismiss()
                onSave(value)
            } label: {
                AnytypeText(Loc.save, style: .previewTitle1Medium)
                    .foregroundColor(haveChanges ? .Text.primary : .Text.tertiary)
            }
            .disabled(!haveChanges)
            
            Spacer.fixedWidth(16)
        }
        .frame(height: 48)
    }
    
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(title, style: .uxCalloutRegular).foregroundColor(.Text.secondary)
            AutofocusedTextField(placeholder: placeholder, font: .bodySemibold, text: $value)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .border(12, color: .System.amber50, lineWidth: 0.5)
        .padding(.horizontal, 16)
    }
}
