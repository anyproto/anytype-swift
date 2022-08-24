import SwiftUI

struct ObjectRelationView: View {
    let options: [Relation.Object.Option]
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if options.isNotEmpty {
            if maxOptions > 0 {
                moreObjectsView
            } else {
                objectsList
            }
        } else {
            RelationsListRowPlaceholderView(hint: hint, style: style)
        }
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style.objectRelationStyle.hSpaсingList) {
                ForEach(options) { option in
                    objectView(option: option)
                }
            }.padding(.horizontal, 1)
        }
    }
    
    private func objectView(option: Relation.Object.Option) -> some View {
        HStack(spacing: style.objectRelationStyle.hSpaсingObject) {
            
            if shouldShowIcon(icon: option.icon) {
                SwiftUIObjectIconImageView(
                    iconImage: option.icon,
                    usecase: style.objectIconImageUsecase
                ).frame(width: style.objectRelationStyle.size.width, height: style.objectRelationStyle.size.height)

            }
            
            AnytypeText(
                option.title,
                style: style.font,
                color: titleColor(option: option)
            )
                .lineLimit(1)
        }
    }
    
    private var moreObjectsView: some View {
        let moreObjectsCount = (options.count - maxOptions) > 0 ? options.count - maxOptions : 0

        return HStack(spacing: style.objectRelationStyle.hSpaсingObject) {
            objectView(options: Array(options.prefix(maxOptions)))

            if moreObjectsCount > 0 {
                countView(count: moreObjectsCount)
            }
        }
        .padding(.horizontal, 1)
    }
    
    private func objectView(options: [Relation.Object.Option]) -> some View {
        ForEach(options) { option in
            objectView(option: option)
        }
    }
    
    private func countView(count: Int) -> some View {
        let optionsCount = "+\(count)"

        return TagView(
            viewModel: TagView.Model(
                text: optionsCount,
                textColor: .textSecondary,
                backgroundColor: UIColor.TagBackground.grey
            ),
            style: style
        )
    }
    
    private func titleColor(option: Relation.Object.Option) -> Color {
        if option.isDeleted || option.isArchived {
            return .textTertiary
        } else {
            return style.fontColor
        }
    }

    private func shouldShowIcon(icon: ObjectIconImage) -> Bool {
        guard case .placeholder = icon else { return true }
        return false
    }
}

extension ObjectRelationView {
    struct ObjectRelationStyle {
        let hSpaсingList: CGFloat
        let hSpaсingObject: CGFloat
        let size: CGSize
    }
    
    private var maxOptions: Int {
        switch style {
        case .regular, .set, .featuredRelationBlock: return 0
        case .filter, .setCollection: return 1
        }
    }
}


struct ObjectRelationView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRelationView(options: [], hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
