import SwiftUI
import DesignKit


struct SettingsInfoEditingViewData: Identifiable {
    let title: String
    let placeholder: String
    let initialValue: String
    let font: AnytypeFont
    let usecase: ThresholdCounterUsecase
    
    let onSave: (String) -> Void
    
    var id: String { usecase.rawValue }
}

struct SettingsInfoEditingView: View {
    private let title: String
    private let placeholder: String
    private let initialValue: String
    private let font: AnytypeFont
    private let usecase: ThresholdCounterUsecase
    
    private let onSave: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    init(_ data: SettingsInfoEditingViewData) {
        title = data.title
        placeholder = data.placeholder
        initialValue = data.initialValue
        font = data.font
        usecase = data.usecase
        onSave = data.onSave
    }
    
    @State private var value: String = ""
    
    private var haveChanges: Bool { value != initialValue }
    private var saveDisabled: Bool { !haveChanges || value.count > usecase.threshold }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            header
            editingView
            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            ThresholdCounter(usecase: usecase, count: value.count)
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
                    .foregroundColor(saveDisabled ? .Text.tertiary: .Text.primary)
            }
            .disabled(saveDisabled)
            
            Spacer.fixedWidth(16)
        }
        .frame(height: 48)
    }
    
    private var editingView: some View {
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(title, style: .uxCalloutRegular).foregroundColor(.Text.secondary)
            AutofocusedTextField(placeholder: placeholder, font: font, axis: .vertical, text: $value)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .border(12, color: .Control.accent50, lineWidth: 2)
        .padding(.horizontal, 16)
    }
}
