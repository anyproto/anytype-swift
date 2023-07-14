import SwiftUI
import AnytypeCore

struct SearchObjectRowView: View {
    
    let viewModel: Model
    let selectionIndicatorViewModel: SelectionIndicatorView.Model?
    
    var body: some View {
        HStack(spacing: 0) {
            if let icon = viewModel.icon {
                SwiftUIObjectIconImageView(
                    iconImage: icon,
                    usecase: .dashboardSearch
                ).frame(
                    width: viewModel.style.iconSize.width,
                    height: viewModel.style.iconSize.height
                )
                Spacer.fixedWidth(12)
            }
            content
            if viewModel.isChecked {
                Image(asset: .X24.tick)
                    .accentColor(.Text.primary)
            }
        }
        .frame(height: viewModel.style.rowHeight)
        .if(FeatureFlags.deleteObjectPlaceholder, if: {
            $0.newDivider()
        }, else: {
            $0.divider(leadingPadding: viewModel.style.leadingDividerPadding)
        })
        .padding(.horizontal, 20)
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                text
                Spacer(minLength: 12)
                selectionIndicatorViewModel.flatMap {
                    SelectionIndicatorView(model: $0)
                }
            }
            Spacer()
        }
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(
                viewModel.title,
                style: viewModel.style.titleFont,
                color: .Text.primary
            ).lineLimit(1)
            if let subtitle = viewModel.subtitle, subtitle.isNotEmpty {
                Spacer.fixedHeight(1)
                AnytypeText(subtitle, style: .relation2Regular, color: .Text.secondary)
                    .lineLimit(1)
            }
        }
    }
    
}

extension SearchObjectRowView {
    
    struct Model {
        let icon: ObjectIconImage?
        let title: String
        let subtitle: String?
        let style: Style
        let isChecked: Bool
        
        enum Style {
            case `default`
            case compact
            
            var rowHeight: CGFloat {
                switch self {
                case .default:
                    return 68
                case .compact:
                    return 52
                }
            }
            
            var iconSize: CGSize {
                switch self {
                case .default:
                    return CGSize(width: 48, height: 48)
                case .compact:
                    return CGSize(width: 24, height: 24)
                }
            }
            
            var leadingDividerPadding: CGFloat {
                switch self {
                case .default:
                    return 60
                case .compact:
                    return 0
                }
            }
            
            var titleFont: AnytypeFont {
                switch self {
                case .default:
                    return .previewTitle2Medium
                case .compact:
                    return .uxBodyRegular
                }
            }
        }
    }
    
}
