import SwiftUI

struct RelationFilesRowView: View {
    
    let file: Relation.File.Option
    
    var body: some View {
        HStack(alignment: .center, spacing: 9) {
            SwiftUIObjectIconImageView(
                iconImage: file.icon,
                usecase: .dashboardSearch
            )
                .frame(width: 18, height: 18)
            
            AnytypeText(file.title, style: .previewTitle2Medium, color: .textPrimary)
                .lineLimit(1)
        }
        .frame(height: 48)
    }
    
}

struct RelationFilesRowView_Previews: PreviewProvider {
    static var previews: some View {
        RelationFilesRowView(
            file: Relation.File.Option(
                id: "s",
                icon: .todo(false),
                title: "title"
            )
        )
    }
}
