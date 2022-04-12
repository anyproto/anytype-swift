import SwiftUI

struct RelationObjectsRowView: View {
    
    let object: Relation.Object.Option
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
            Spacer.fixedWidth(12)
            text
            Spacer()
        }
        .frame(height: 68)
    }
    
    private var icon: some View {
        Group {
            if object.isDeleted {
                Image.ghost.resizable().frame(width: 28, height: 28)
            } else {
                SwiftUIObjectIconImageView(
                    iconImage: object.icon,
                    usecase: .dashboardSearch
                )
            }
        }.frame(width: 48, height: 48)
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(
                object.isDeleted ? "Non-existent object".localized : object.title,
                style: .previewTitle2Medium,
                color: object.isDeleted ? .textTertiary : .textPrimary
            )
                .lineLimit(1)
            
            Spacer.fixedHeight(1)
            
            AnytypeText(
                object.isDeleted ? "Deleted".localized : object.type,
                style: .relation2Regular,
                color: object.isDeleted ? .textTertiary : .textSecondary
            )
                .lineLimit(1)
        }
    }
    
}

struct RelationObjectsRowView_Previews: PreviewProvider {
    static var previews: some View {
        RelationObjectsRowView(
            object: Relation.Object.Option(
                id: "",
                icon: .placeholder("r"),
                title: "title",
                type: "type",
                isDeleted: false
            )
        )
    }
}
