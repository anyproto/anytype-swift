import SwiftUI

struct RelationObjectsRowView: View {
    
    let object: Relation.Object.Option
    let action: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
            Spacer.fixedWidth(12)
            text
            Spacer()
        }
        .frame(height: 68)
        .onTapGesture {
            action()
        }
    }
    
    private var icon: some View {
        Group {
            if object.isDeleted {
                Image(asset: .ghost).resizable().frame(width: 28, height: 28)
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
                object.isDeleted ? Loc.nonExistentObject : object.title,
                style: .previewTitle2Medium,
                color: titleColor
            )
                .lineLimit(1)
            
            Spacer.fixedHeight(1)
            
            AnytypeText(
                object.isDeleted ? Loc.deleted : object.type,
                style: .relation2Regular,
                color: subtitleColor
            )
                .lineLimit(1)
        }
    }
    
    private var titleColor: Color {
        if object.isDeleted || object.isArchived {
            return .TextNew.tertiary
        } else {
            return .TextNew.primary
        }
    }
    
    private var subtitleColor: Color {
        if object.isDeleted || object.isArchived {
            return .TextNew.tertiary
        } else {
            return .TextNew.secondary
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
                isArchived: false,
                isDeleted: false,
                editorViewType: .page
            ),
            action: {}
        )
    }
}
