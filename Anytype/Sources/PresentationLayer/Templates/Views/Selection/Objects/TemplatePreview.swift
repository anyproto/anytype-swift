import SwiftUI
import Services

struct TemplatePreview: View {
    let viewModel: TemplatePreviewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.clear)
            content
        }
        .border(
            16,
            color: viewModel.isDefault ?
            Color.System.amber50 : .Stroke.primary,
            lineWidth: viewModel.isDefault ? 2 : 1
        )
        .cornerRadius(16, corners: .top)
        .frame(width: 120, height: 224)
    }
    
    var content: some View {
        VStack(alignment: viewModel.alignment.horizontalAlignment) {
            cover
            switch viewModel.model {
            case .blank:
                AnytypeText(
                    "Blank",
                    style: .caption2Medium,
                    color: .Text.tertiary
                ).padding(.horizontal, 16)
            case let .installed(templateModel):
                AnytypeText(
                    templateModel.title,
                    style: .caption2Medium,
                    color: .Text.primary
                ).padding(.horizontal, 16)
            }
            Spacer.fixedHeight(12)
            shimmer.padding(.horizontal, 16)
            Spacer()
        }
    }
    
    private var cover: some View {
        Group {
            if case let .installed(templateModel) = viewModel.model {
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
            switch viewModel.alignment {
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
}

struct TemplatePreview_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(MockTemplatePreviewModel.allPreviews) {
            TemplatePreview(
                viewModel: $0.model
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
