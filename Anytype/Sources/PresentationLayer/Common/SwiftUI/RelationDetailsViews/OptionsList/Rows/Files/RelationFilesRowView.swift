import SwiftUI

struct RelationFilesRowView: View {
    
    let file: RelationValue.File.Option
    let action: (() -> Void)
    
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
        .onTapGesture {
            action()
        }
    }
    
}

struct RelationFilesRowView_Previews: PreviewProvider {
    static var previews: some View {
        RelationFilesRowView(
            file: RelationValue.File.Option(
                id: "s",
                icon: .todo(false),
                title: "title"
            ),
            action: {}
        )
    }
}
