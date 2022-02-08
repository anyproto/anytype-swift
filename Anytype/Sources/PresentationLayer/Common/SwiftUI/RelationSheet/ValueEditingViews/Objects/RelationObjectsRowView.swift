import SwiftUI

struct RelationObjectsRowView: View {
    
    let object: Relation.Object.Option
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: object.icon,
                usecase: .dashboardSearch
            ).frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
            text
            Spacer()
        }
        .frame(height: 64)
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(object.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
            Spacer.fixedHeight(1)
            
            AnytypeText(object.type, style: .relation2Regular, color: .textSecondary)
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
                type: "type"
            )
        )
    }
}
