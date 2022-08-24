import SwiftUI

struct FileRelationView: View {
    let options: [Relation.File.Option]
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
                ForEach(options) { objectView(option: $0) }
            }
            .padding(.horizontal, 1)
        }
    }
    
    private func objectView(option: Relation.File.Option) -> some View {
        HStack(spacing: style.objectRelationStyle.hSpaсingObject) {
            SwiftUIObjectIconImageView(
                iconImage: option.icon,
                usecase: style.objectIconImageUsecase
            ).frame(width: style.objectRelationStyle.size.width, height: style.objectRelationStyle.size.height)

            
            AnytypeText(
                option.title,
                style: style.font,
                color: style.fontColor
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
    
    private func objectView(options: [Relation.File.Option]) -> some View {
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
}

extension FileRelationView {
    private var maxOptions: Int {
        switch style {
        case .regular, .set, .featuredRelationBlock: return 0
        case .filter, .setCollection: return 1
        }
    }
}


struct FileRelationView_Previews: PreviewProvider {
    static var previews: some View {
        FileRelationView(options: [], hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
