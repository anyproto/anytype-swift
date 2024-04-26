import SwiftUI
import AnytypeCore

struct ObjectRelationOptionView: View {
    
    let option: ObjectRelationOption
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            icon
            text
        }
        .frame(height: 68, alignment: .leading)
    }
    
    @ViewBuilder
    private var icon: some View {
        if option.isDeleted {
            Group {
                Image(asset: .ghost).resizable().frame(width: 28, height: 28)
            }.frame(width: 48, height: 48)
        } else if let icon = option.icon {
            IconView(icon: icon)
                .frame(width: 48, height: 48)
        }
    }
    
    private var text: some View {
        VStack(alignment: .leading, spacing: 1) {
            AnytypeText(
                option.isDeleted ? Loc.nonExistentObject : option.title,
                style: .uxTitle2Regular,
                color: option.isUnavailable ? .Text.tertiary : .Text.primary
            )
            .lineLimit(1)
            
            AnytypeText(
                option.isDeleted ? Loc.deleted : option.type,
                style: .relation3Regular,
                color: option.isUnavailable ? .Text.secondary : .Text.tertiary
            )
            .lineLimit(1)
        }
    }
}

#Preview("ObjectOptionView") {
    ObjectRelationOptionView(
        option: ObjectRelationOption(
            id: "",
            icon: nil,
            title: "File",
            type: "File",
            isArchived: false,
            isDeleted: false,
            disableDeletion: false,
            disableDuplication: false,
            editorScreenData: nil
        )
    )
}

