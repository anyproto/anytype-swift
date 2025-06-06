import SwiftUI
import Services
import AnytypeCore


struct NewPropertyRestrictionsSectionView: View {
    
    let model: [ObjectTypeModel]
    
    var body: some View {
        if model.isNotEmpty {
            filledView
        } else {
            emptyView
        }
    }
    
    private var emptyView: some View {
        AnytypeText(Loc.none, style: .uxBodyRegular)
            .foregroundColor(.Text.primary)
            .lineLimit(1)
    }
    
    private var filledView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model) { objectTypeModel in
                    objectTypeView(model: objectTypeModel)
                    Spacer.fixedWidth(10)
                }
                Spacer.fixedWidth(30)
            }
        }
        .transparencyEffect(edge: .trailing, length: 40)
    }
    
    private func objectTypeView(model: ObjectTypeModel) -> some View {
        HStack(spacing: 5) {
            IconView(object: model.icon).frame(width: 20, height: 20)
            
            AnytypeText(model.title, style: .uxBodyRegular)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
        }
    }
}

extension NewPropertyRestrictionsSectionView {    
    struct ObjectTypeModel: Identifiable, Hashable {
        let id: String
        let icon: ObjectIcon
        let title: String
    }
    
}

struct NewPropertyRestrictionsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        NewPropertyRestrictionsSectionView(
            model: [
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .customIcon(CustomIconData(icon: .man, customColor: .gray)),
                    title: "custom icon title 1"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .customIcon(CustomIconData(icon: .transgender, customColor: .pink)),
                    title: "custom icon title 2"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .customIcon(CustomIconData(icon: .telescope, customColor: .amber)),
                    title: "custom icon title 3"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .emoji(Emoji("📘")!),
                    title: "title 2"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .emoji(Emoji("🐭")!),
                    title: "title 1"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .emoji(Emoji("📘")!),
                    title: "title 2"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .emoji(Emoji("🤡")!),
                    title: "title 2"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .emoji(Emoji("🤡")!),
                    title: "title 2"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .emoji(Emoji("🤡")!),
                    title: "title 2"
                ),
                NewPropertyRestrictionsSectionView.ObjectTypeModel(
                    id: UUID().uuidString,
                    icon: .emoji(Emoji("🤡")!),
                    title: "title 2"
                )
            ]
        )
            
    }
}
