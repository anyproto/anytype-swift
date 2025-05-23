import SwiftUI
import Services

struct TextPropertyEditingView: View {
    
    @StateObject var viewModel: TextPropertyEditingViewModel
    @Environment(\.dismiss) var dismiss
    
    init(data: TextPropertyEditingViewData) {
        _viewModel = StateObject(wrappedValue: TextPropertyEditingViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            content
        }
        .background(Color.Background.secondary)
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
        .onChange(of: viewModel.text) { newText in
            viewModel.onTextChanged(newText)
        }
        .task {
            viewModel.updatePasteState()
        }
        .task {
            await viewModel.handlePasteboard()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
        .fitPresentationDetents()
        .ignoresSafeArea()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            toolbar
            if viewModel.text.isEmpty, !viewModel.config.isEditable {
                PropertyListEmptyState()
            } else {
                contentView
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var toolbar: some View {
        HStack(spacing: 0) {
            clearButton
                .frame(maxWidth: 100, alignment: .leading)
            
            AnytypeText(viewModel.config.title, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            pasteButton
                .frame(maxWidth: 100, alignment: .trailing)
        }
        .frame(height: 48)
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
            buttons
            Spacer.fixedHeight(6)
        }
    }
    
    @ViewBuilder
    private var textField: some View {
        TextField(viewModel.type.placeholder, text: $viewModel.text, axis: .vertical)
            .lineLimit(1...10)
    }
    
    @ViewBuilder
    private var clearButton: some View {
        if viewModel.text.isNotEmpty, viewModel.config.isEditable {
            Button {
                viewModel.onClear()
            } label: {
                AnytypeText(Loc.clear, style: .uxBodyRegular)
                    .foregroundColor(.Control.active)
            }
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    private var pasteButton: some View {
        if viewModel.showPaste, viewModel.config.isEditable {
            Button {
                viewModel.onPaste()
            } label: {
                AnytypeText(Loc.paste, style: .uxBodyRegular)
                    .foregroundColor(.Control.active)
            }
        } else {
            Spacer()
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 0) {
            if viewModel.actionsViewModels.isNotEmpty {
                Spacer.fixedHeight(12)
            }
            ForEach(viewModel.actionsViewModels, id: \.id) { model in
                Divider()
                Button {
                    model.performAction()
                } label: {
                    HStack(spacing: 0) {
                        Image(asset: model.iconAsset)
                            .foregroundColor(model.isActionAvailable ? .Control.active : .Control.inactive)
                        Spacer.fixedWidth(10)
                        AnytypeText(
                            model.title,
                            style: .bodyRegular
                        )
                        .foregroundColor(model.isActionAvailable ? .Text.primary : .Text.tertiary)
                        .lineLimit(1)
                        Spacer()
                    }
                    .frame(height: 52)
                    .fixTappableArea()
                }
                .disabled(!model.isActionAvailable)
            }
        }
    }
}

#Preview {
    TextPropertyEditingView(
        data: .init(
            text: nil, 
            type: .text,
            config: PropertyModuleConfiguration.default,
            objectDetails: .deleted,
            output: nil
        )
    )
}
