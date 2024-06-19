import Foundation
import SwiftUI

struct TreeWidgetRowViewModel {
    
    enum ExpandedType {
        case arrow(expanded: Bool)
        case icon(asset: ImageAsset)
    }
    
    let rowId: String
    let objectId: String
    let title: String
    let icon: Icon?
    let expandedType: ExpandedType
    let level: Int
    let tapExpand: (TreeWidgetRowViewModel) -> Void
    let tapCollapse: (TreeWidgetRowViewModel) -> Void
    let tapObject: (TreeWidgetRowViewModel) -> Void
}

struct TreeWidgetRowView: View {
    
    let model: TreeWidgetRowViewModel
    let showDivider: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer.fixedWidth(16 * CGFloat(model.level + 1))
            rowIcon
            Spacer.fixedWidth(8)
            HStack(alignment: .center, spacing: 0) {
                if let icon = model.icon {
                    IconView(icon: icon)
                        .frame(width: 18, height: 18)
                    Spacer.fixedWidth(12)
                }
                AnytypeText(model.title, style: .previewTitle2Medium)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                Spacer.fixedWidth(12)
                Spacer()
            }
            .fixTappableArea()
            .onTapGesture {
                model.tapObject(model)
            }
        }
        .frame(height: 40)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
    }
    
    // MARK: - Private
    private var rowIcon: some View {
        Group {
            switch model.expandedType {
            case let .icon(asset):
                Image(asset: asset)
            case let .arrow(expanded: expanded):
                Image(asset: .Widget.collapse)
                    .rotationEffect(.degrees(expanded ? 90 : 0))
                    .increaseTapGesture(EdgeInsets(side: 10)) {
                        withAnimation {
                            if expanded {
                                model.tapCollapse(model)
                            } else {
                                model.tapExpand(model)
                            }
                        }
                    }
            }
        }
        .foregroundColor(.Text.primary)
        .frame(width: 20, height: 20)
    }
}
