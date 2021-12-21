import SwiftUI

struct RelationObjectsSearchRowView: View {
    
    let data: RelationObjectsSearchData
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            SwiftUIObjectIconImageView(
                iconImage: data.iconImage,
                usecase: .dashboardSearch
            ).frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
            text
            Spacer()
        }
        .frame(height: 64)
        .padding(.horizontal, 20)
        .modifier(DividerModifier(spacing: 0, leadingPadding: 80, trailingPadding: 20))
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(data.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
            Spacer.fixedHeight(1)
            AnytypeText(data.subtitle, style: .relation2Regular, color: .textSecondary)
                .lineLimit(1)
        }
    }
}

struct RelationObjectsSearchRowView_Previews: PreviewProvider {
    static var previews: some View {
        RelationObjectsSearchRowView(
            data: RelationObjectsSearchData(
                id: "id",
                iconImage: .todo(true),
                title: "title",
                subtitle: "subtitle"
            )
        )
    }
}
