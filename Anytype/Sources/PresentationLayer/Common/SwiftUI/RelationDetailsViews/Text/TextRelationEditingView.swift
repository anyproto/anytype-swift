import SwiftUI
import Services

struct TextRelationEditingView: View {
    
    @StateObject var viewModel: TextRelationEditingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            toolbar
            contentView
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
        .fitPresentationDetents()
        .ignoresSafeArea()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            toolbar
            contentView
        }
        .padding(.horizontal, 20)
    }
    
    private var toolbar: some View {
        HStack(spacing: 0) {
            clearButton
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TitleView(title: viewModel.config.title)
                .frame(maxWidth: .infinity)
            
            pasteButton
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(height: 48)
        .padding(.horizontal, 20)
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
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var textField: some View {
        if #available(iOS 16.0, *) {
            TextField(viewModel.type.placeholder, text: $viewModel.text, axis: .vertical)
                .lineLimit(1...10)
        } else {
            TextField(viewModel.type.placeholder, text: $viewModel.text)
                .frame(height: 48)
        }
    }
    
    @ViewBuilder
    private var clearButton: some View {
        if viewModel.text.isNotEmpty, viewModel.config.isEditable {
            Button {
                viewModel.onClear()
            } label: {
                AnytypeText(Loc.clear, style: .uxBodyRegular, color: .Button.active)
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
                AnytypeText(Loc.paste, style: .uxBodyRegular, color: .Button.active)
            }
        } else {
            Spacer()
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 0) {
            if viewModel.actionsViewModel.isNotEmpty {
                Spacer.fixedHeight(12)
            }
            ForEach(viewModel.actionsViewModel, id: \.id) { model in
                Divider()
                Button {
                    model.performAction()
                } label: {
                    HStack(spacing: 0) {
                        Image(asset: model.iconAsset)
                            .foregroundColor(model.isActionAvailable ? .Button.active : .Button.inactive)
                        Spacer.fixedWidth(10)
                        AnytypeText(
                            model.title,
                            style: .bodyRegular,
                            color: model.isActionAvailable ? .Text.primary : .Text.tertiary
                        ).lineLimit(1)
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
    TextRelationEditingView(
        viewModel: TextRelationEditingViewModel(
            text: nil, 
            type: .text,
            config: RelationModuleConfiguration.default,
            actionsViewModel: [],
            service: DI.preview.serviceLocator.textRelationEditingService(), 
            pasteboardHelper: DI.preview.serviceLocator.pasteboardHelper()
        )
    )
}
