import SwiftUI
import Services

struct TemplatePreview: View, ContextualMenuItemsProvider {
    let viewModel: TemplatePreviewViewModel
    
    var body: some View {
        content
            .if(viewModel.model.decoration == .border, if: {
                $0.border(16, color: Color.Control.accent50, lineWidth: 2)
            }, else: {
                $0.border(16, color: .Shape.primary, lineWidth: 1)
            })
        .cornerRadius(16, corners: .top)
        .frame(width: 120, height: 224)
    }
    
    var content: some View {
        Group {
            switch viewModel.model.mode {
            case let .installed(templateModel):
                wrapped(shouldIncludeShimmer: true) {
                    switch templateModel.style {
                    case .none:
                        AnytypeText(
                            templateModel.title,
                            style: .caption2Medium
                        )
                        .foregroundColor(.Text.primary)
                        .padding(.horizontal, 16)
                    case let .todo(isChecked):
                        HStack(spacing: 4) {
                            IconView(icon: .object(.todo(isChecked, nil))).frame(width: 14, height: 14)
                            AnytypeText(
                                templateModel.title,
                                style: .caption2Medium
                            )
                            .foregroundColor(.Text.primary)
                            .lineLimit(1)
                        }.padding(.horizontal, 16)
                    }
                    
                }
            case .addTemplate:
                Image(asset: .X32.plus)
                    .tint(.Control.secondary)
            }
        }
        .frame(width: 120, height: 224)
        .if(viewModel.model.decoration == .defaultBadge) {
            $0.overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    AnytypeText("Default", style: .relation2Regular)
                        .foregroundColor(.Text.secondary)
                        .padding(.horizontal, 6)
                        .background(Color.Shape.transperentSecondary)
                        .cornerRadius(4, style: .continuous)
                    Spacer.fixedHeight(8)
                }
            }
        }
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
            case .left, .justify, .UNRECOGNIZED:
                shimmerRectangle.padding(.trailing, 24)
            }
        }
    }
    
    var shimmerRectangle: some View {
        Rectangle()
            .fill(Color.Shape.secondary)
            .border(1, color: .clear)
            .frame(height: 6)
    }
    
    @ViewBuilder
    var contextMenuItems: AnyView {
        Group {
            ForEach(viewModel.model.contextualMenuOptions, id: \.self) {
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
        case .left, .justify, .UNRECOGNIZED:
            return .leading
        case .center:
            return .center
        case .right:
            return .trailing
        }
    }
}
