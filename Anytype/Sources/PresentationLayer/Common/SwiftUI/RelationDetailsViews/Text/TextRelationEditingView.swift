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
        .background(Color.Background.secondary)
        .onChange(of: viewModel.dismiss) { _ in
            dismiss()
        }
        .onChange(of: viewModel.text) { newText in
            viewModel.onTextChanged(newText)
        }
        .frame(height: totalHeight())
        .fitPresentationDetents()
    }
    
    private var content: some View {
        NavigationView {
            contentView
                .padding(.horizontal, 20)
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
            buttons
            Spacer()
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
    
    private var buttons: some View {
        VStack(spacing: 0) {
            if viewModel.actionsViewModel.isNotEmpty {
                Spacer.fixedHeight(Constants.innerSpace)
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
    
    func totalHeight() -> CGFloat {
        Constants.basicHeight + 
        CGFloat(viewModel.actionsViewModel.count) * Constants.actionHeight +
        Constants.innerSpace
    }
}

extension TextRelationEditingView {
    enum Constants {
        static let basicHeight: CGFloat = 140
        static let actionHeight: CGFloat = 52
        static let innerSpace: CGFloat = 12
    }
}

#Preview {
    TextRelationEditingView(
        viewModel: TextRelationEditingViewModel(
            text: nil, 
            type: .text,
            config: RelationModuleConfiguration.default,
            actionsViewModel: [],
            service: DI.preview.serviceLocator.textRelationEditingService()
        )
    )
}
