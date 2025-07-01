
import SwiftUI

struct SetTableViewRow: View {
    
    @ObservedObject var model: EditorSetViewModel
    let configuration: SetContentViewItemConfiguration
    let xOffset: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(18)
            details
            Spacer.fixedHeight(18)
            cells
            Spacer.fixedHeight(12)
            AnytypeDivider()
        }
        .fixTappableArea()
    }
    
    private var details: some View {
        HStack(spacing: 0) {
            icon
            title
        }
        .padding(.horizontal, 16)
        .offset(x: xOffset, y: 0)
    }
    
    private var icon: some View {
        Group {
            if configuration.showIcon {
                IconView(icon: configuration.icon).frame(width: 18, height: 18)
                    .padding(.trailing, 8)
                    .disabled(!model.setDocument.setPermissions.canEditSetObjectIcon)
            }
        }
    }
    
    private var title: some View {
        Button {
            configuration.onItemTap()
        } label: {
            AnytypeText(configuration.title, style: .previewTitle2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
        }
    }
    
    private var cells: some View {
        LazyHStack(spacing: 0) {
            ForEach(configuration.relations) { colum in
                Spacer.fixedWidth(16)
                cell(colum)
                Rectangle()
                    .frame(width: 0.5, height: 18)
                    .foregroundColor(.Shape.primary)
            }
        }
        .frame(height: 18)
    }
    
    private func cell(_ relation: Property) -> some View {
        PropertyValueView(
            model: PropertyValueViewModel(
                property: PropertyItemModel(property: relation),
                style: .set,
                mode: .button(action: {
                    model.showRelationValueEditingView(
                        objectId: configuration.id,
                        relation: relation
                    )
                })
            )
        )
        .frame(width: 128)
    }
}
