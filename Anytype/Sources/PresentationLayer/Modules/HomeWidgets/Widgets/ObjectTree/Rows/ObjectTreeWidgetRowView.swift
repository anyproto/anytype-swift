import Foundation
import SwiftUI

struct ObjectTreeWidgetRowViewModel {
    
    enum ExpandedType {
        case set
        case arrow(expanded: Bool)
        case dot
    }
    
    let rowId: String
    let objectId: String
    let title: String
    let icon: ObjectIconImage?
    let expandedType: ExpandedType
    let level: Int
    let tapExpand: (ObjectTreeWidgetRowViewModel) -> Void
    let tapCollapse: (ObjectTreeWidgetRowViewModel) -> Void
    let tapObject: (ObjectTreeWidgetRowViewModel) -> Void
}

struct ObjectTreeWidgetRowView: View {
    
    let model: ObjectTreeWidgetRowViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer.fixedWidth(16 * CGFloat(model.level + 1))
            rowIcon
                .frame(width: 20, height: 20)
            Spacer.fixedWidth(8)
            Button(action: {
                model.tapObject(model)
            }, label: {
                if let icon = model.icon {
                    SwiftUIObjectIconImageView(iconImage: icon, usecase: .widgetTree)
                        .frame(width: 18, height: 18)
                    Spacer.fixedWidth(12)
                }
                AnytypeText(model.title, style: .previewTitle2Medium, color: .Text.primary)
                    .lineLimit(1)
                Spacer.fixedWidth(12)
                Spacer()
            })
        }
        .frame(height: 40)
        .newDivider(leadingPadding: 16, trailingPadding: 16)
    }
    
    // MARK: - Private
    private var rowIcon: some View {
        Group {
            switch model.expandedType {
            case .dot:
                Image(asset: .Widget.dot)
            case .set:
                Image(asset: .Widget.set)
            case let .arrow(expanded: expanded):
                Button(action: {
                    withAnimation {
                        if expanded {
                            model.tapCollapse(model)
                        } else {
                            model.tapExpand(model)
                        }
                    }
                }, label: {
                    Image(asset: .Widget.collapse)
                        .rotationEffect(.degrees(expanded ? 90 : 0))
                })
                
            }
        }
    }
}
