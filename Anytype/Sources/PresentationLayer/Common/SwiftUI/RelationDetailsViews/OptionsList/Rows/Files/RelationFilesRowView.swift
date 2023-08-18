import SwiftUI

struct RelationFilesRowView: View {
    
    let file: Relation.File.Option
    let action: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center, spacing: 9) {
            if let icon = file.icon {
                SwiftUIObjectIconImageView(
                    iconImage: icon,
                    usecase: .dashboardSearch
                )
                .frame(width: 48, height: 48)
            }
            
            AnytypeText(file.title, style: .previewTitle2Medium, color: .Text.primary)
                .lineLimit(1)
        }
        .frame(height: 48)
        .onTapGesture {
            action()
        }
    }
    
}

struct RelationFilesRowView_Previews: PreviewProvider {
    static var previews: some View {
        RelationFilesRowView(
            file: Relation.File.Option(
                id: "s",
                icon: .todo(false),
                title: "title",
                editorScreenData: .favorites
            ),
            action: {}
        )
    }
}
