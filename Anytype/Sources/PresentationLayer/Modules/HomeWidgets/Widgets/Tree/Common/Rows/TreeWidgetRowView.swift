import Foundation
import SwiftUI

struct TreeWidgetRowViewModel: Identifiable, Equatable {

    enum ExpandedType: Equatable {
        case arrow(expanded: Bool)
        case icon(asset: ImageAsset)
    }

    let rowId: String
    let objectId: String
    let title: String
    let icon: Icon
    let expandedType: ExpandedType
    let level: Int
    @EquatableNoop var tapExpand: (TreeWidgetRowViewModel) -> Void
    @EquatableNoop var tapCollapse: (TreeWidgetRowViewModel) -> Void
    @EquatableNoop var tapObject: (TreeWidgetRowViewModel) -> Void

    var id: String { rowId }
}

struct TreeWidgetRowView: View {
    
    let model: TreeWidgetRowViewModel
    let showDivider: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer.fixedWidth(16 * CGFloat(model.level + 1))
            rowIcon
            Spacer.fixedWidth(8)
            Button {
                model.tapObject(model)
            } label: {
                HStack(alignment: .center, spacing: 0) {
                    IconView(icon: model.icon)
                        .frame(width: 18, height: 18)
                    Spacer.fixedWidth(12)

                    AnytypeText(model.title, style: .previewTitle2Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    Spacer.fixedWidth(12)
                    Spacer()
                }
                .fixTappableArea()
            }
            .buttonStyle(.plain)
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
                Image(asset: .X18.Disclosure.right)
                    .rotationEffect(.degrees(expanded ? 90 : 0))
                    .increaseTapGesture(EdgeInsets(side: 10)) {
                        withAnimation(.disclosureSmall) {
                            if expanded {
                                model.tapCollapse(model)
                            } else {
                                model.tapExpand(model)
                            }
                        }
                    }
            }
        }
        .foregroundStyle(Color.Text.primary)
    }
}
