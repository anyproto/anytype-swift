import SwiftUI

struct StatusRelationView: View {
    let options: [Relation.Status.Option]
    let hint: String
    let style: RelationStyle
    
    var body: some View {
        if options.isNotEmpty {
            if maxOptions > 0 {
                moreStatusesView
            } else {
                statusList
            }
        } else {
            RelationsListRowPlaceholderView(hint: hint, style: style)
        }
    }
    
    private var statusList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style.objectRelationStyle.hSpaсingList) {
                ForEach(options) { option in
                    statusView(option: option)
                }
            }.padding(.horizontal, 1)
        }
    }
    
    private func statusView(option: Relation.Status.Option) -> some View {
        AnytypeText(option.text, style: style.font, color: option.color.suColor)
            .lineLimit(1)
    }
    
    private var moreStatusesView: some View {
        let moreObjectsCount = (options.count - maxOptions) > 0 ? options.count - maxOptions : 0

        return HStack(spacing: style.objectRelationStyle.hSpaсingObject) {
            statusView(options: Array(options.prefix(maxOptions)))

            if moreObjectsCount > 0 {
                CountTagView(count: moreObjectsCount, style: style)
            }
        }
        .padding(.horizontal, 1)
    }
    
    private func statusView(options: [Relation.Status.Option]) -> some View {
        ForEach(options) { option in
            statusView(option: option)
        }
    }
}

extension StatusRelationView {
    private var maxOptions: Int {
        switch style {
        case .regular, .set, .featuredRelationBlock: return 0
        case .filter, .setCollection, .kanbanHeader: return 1
        }
    }
}

struct StatusRelationView_Previews: PreviewProvider {
    static var previews: some View {
        StatusRelationView(
            options: [Relation.Status.Option(
                id: "id",
                text: "text",
                color: UIColor.Dark.amber
            )],
            hint: "hint",
            style: .regular(allowMultiLine: false)
        )
    }
}
