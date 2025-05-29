import SwiftUI

struct StatusPropertyView: View {
    let options: [Relation.Status.Option]
    let hint: String
    let style: PropertyStyle
    
    var body: some View {
        if options.isNotEmpty {
            if maxOptions > 0 {
                moreStatusesView
            } else {
                statusList
            }
        } else {
            PropertyValuePlaceholderView(hint: hint, style: style)
        }
    }
    
    private var statusList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style.objectPropertyStyle.hSpaсingList) {
                ForEach(options) { option in
                    statusView(option: option)
                }
            }.padding(.horizontal, 1)
        }
    }
    
    private func statusView(option: Relation.Status.Option) -> some View {
        AnytypeText(option.text, style: style.font)
            .foregroundColor(option.color)
            .lineLimit(1)
    }
    
    private var moreStatusesView: some View {
        let moreObjectsCount = (options.count - maxOptions) > 0 ? options.count - maxOptions : 0

        return HStack(spacing: style.objectPropertyStyle.hSpaсingObject) {
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

extension StatusPropertyView {
    private var maxOptions: Int {
        switch style {
        case .filter, .setCollection, .kanbanHeader, .regular, .featuredBlock: return 1
        case .set: return 0
        }
    }
}

struct StatusRelationView_Previews: PreviewProvider {
    static var previews: some View {
        StatusPropertyView(
            options: [Relation.Status.Option(
                id: "id",
                text: "text",
                color: Color.Dark.yellow
            )],
            hint: "hint",
            style: .regular(allowMultiLine: false)
        )
    }
}
