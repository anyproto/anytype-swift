import SwiftUI
import Services

struct TemplatePreview: View, ContextualMenuItemsProvider {
    let viewModel: TemplatePreviewViewModel
    
    var body: some View {
        content
        .border(
            16,
            color: viewModel.model.isDefault ?
            Color.System.amber50 : .Stroke.primary,
            lineWidth: viewModel.model.isDefault ? 2 : 1
        )
        .cornerRadius(16, corners: .top)
        .frame(width: 120, height: 224)
    }
    
    var content: some View {
        Group {
            switch viewModel.model.mode {
            case .blank:
                wrapped(shouldIncludeShimmer: false) {
                    AnytypeText(
                        Loc.TemplateSelection.blankTemplate,
                        style: .caption2Medium,
                        color: .Text.tertiary
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }
            case let .installed(templateModel):
                wrapped(shouldIncludeShimmer: true) {
                    AnytypeText(
                        templateModel.title,
                        style: .caption2Medium,
                        color: .Text.primary
                    ).padding(.horizontal, 16)
                }
            case .addTemplate:
                Image(asset: .X32.plus)
                    .tint(.Button.active)
            }
        }
        .frame(width: 120, height: 224)
    }
    
    @ViewBuilder
    private func wrapped(
        shouldIncludeShimmer: Bool,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: viewModel.model.alignment.horizontalAlignment) {
            cover
            content()
            if shouldIncludeShimmer {
                Spacer.fixedHeight(12)
                shimmer.padding(.horizontal, 16)
            }
            Spacer()
        }
    }
    
    private var cover: some View {
        Group {
            if case let .installed(templateModel) = viewModel.model.mode {
                switch templateModel.header {
                case .filled(let state, _):
                    ObjectHeaderFilledContentSwitfUIView(
                        configuration: ObjectHeaderFilledConfiguration(
                            state: state,
                            isShimmering: false,
                            sizeConfiguration: .templatePreviewSizeConfiguration
                        )
                    )
                default:
                    Spacer.fixedHeight(28)
                }
            } else {
                Spacer.fixedHeight(28)
            }
        }
    }
    
    var shimmer: some View {
        VStack(spacing: 6) {
            shimmerRectangle
            shimmerRectangle
            switch viewModel.model.alignment {
            case .center:
                shimmerRectangle.padding(.horizontal, 12)
            case .right:
                shimmerRectangle.padding(.leading, 24)
            case .left:
                shimmerRectangle.padding(.trailing, 24)
            }
        }
    }
    
    var shimmerRectangle: some View {
        Rectangle()
            .fill(Color.Stroke.secondary)
            .border(1, color: .clear)
            .frame(height: 6)
    }
    
    @ViewBuilder
    var contextMenuItems: AnyView {
        Group {
            ForEach(TemplateOptionAction.allCases, id: \.self) {
                menuItemToView(option: $0)
            }
            Divider()
        }.eraseToAnyView()
    }
    
    @ViewBuilder
    func menuItemToView(option: TemplateOptionAction) -> some View {
        Button(option.title, role: option.style) {
            viewModel.onOptionSelection(option)
        }
    }
}

struct TemplatePreview_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(MockTemplatePreviewModel.allPreviews) {
            TemplatePreview(
                viewModel: .init(
                    model: $0.model,
                    onOptionSelection: { _ in }
                )
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName($0.title)
        }
    }
}

extension LayoutAlignment {
    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .left:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }
}
