import SwiftUI
import Services

struct TextRelationEditingView: View {
    
    @StateObject var viewModel: TextRelationEditingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            content
        }
        .frame(height: 140)
        .background(Color.Background.secondary)
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
        .onChange(of: viewModel.text) { newText in
            viewModel.onTextChanged(newText)
        }
        .fitPresentationDetents()
    }
    
    private var content: some View {
        NavigationView {
            contentView
                .padding(.horizontal, 16)
                .navigationTitle(viewModel.config.title)
                .navigationBarTitleDisplayMode(.inline)
                .if(viewModel.config.isEditable) {
                    $0.toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            if viewModel.text.isNotEmpty {
                                clearButton
                            }
                        }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(6)
            textField
                .focused($viewModel.textFocused)
                .font(AnytypeFontBuilder.font(anytypeFont: .uxBodyRegular))
                .keyboardType(viewModel.type.keyboardType)
                .disabled(!viewModel.config.isEditable)
        }
    }
    
    @ViewBuilder
    private var textField: some View {
        if #available(iOS 16.0, *) {
            TextField(viewModel.type.placeholder, text: $viewModel.text, axis: .vertical)
                .lineLimit(3, reservesSpace: true)
        } else {
            TextField(viewModel.type.placeholder, text: $viewModel.text)
                .frame(height: 48)
        }
    }
    
    private var clearButton: some View {
        Button {
            viewModel.onClear()
        } label: {
            AnytypeText(Loc.clear, style: .uxBodyRegular, color: .Button.active)
        }
    }
}

#Preview {
    TextRelationEditingView(
        viewModel: TextRelationEditingViewModel(
            text: nil, 
            type: .text,
            config: RelationModuleConfiguration.default,
            service: DI.preview.serviceLocator.textRelationEditingService()
        )
    )
}
