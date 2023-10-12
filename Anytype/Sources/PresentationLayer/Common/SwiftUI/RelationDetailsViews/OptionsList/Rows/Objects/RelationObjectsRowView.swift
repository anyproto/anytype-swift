import SwiftUI
import AnytypeCore

struct RelationObjectsRowView: View {
    
    let object: Relation.Object.Option
    let action: (() -> Void)
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            icon
            text
            Spacer()
        }
        .frame(height: 68)
        .onTapGesture {
            action()
        }
    }
    
    @ViewBuilder
    private var icon: some View {
        if object.isDeleted {
            Group {
                Image(asset: .ghost).resizable().frame(width: 28, height: 28)
            }.frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
        }
        else if let icon = object.icon {
            IconView(icon: icon)
                .frame(width: 48, height: 48)
            Spacer.fixedWidth(12)
        }
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
            return .Text.tertiary
        } else {
            return .Text.primary
        }
    }
    
    private var subtitleColor: Color {
        if object.isDeleted || object.isArchived {
            return .Text.tertiary
        } else {
            return .Text.secondary
        }
    }
    
}

struct RelationObjectsRowView_Previews: PreviewProvider {
    static var previews: some View {
        RelationObjectsRowView(
            object: Relation.Object.Option(
                id: "",
                icon: .object(.placeholder("r")),
                title: "title",
                type: "type",
                isArchived: false,
                isDeleted: false,
                editorScreenData: .favorites
            ),
            action: {}
        )
    }
}
