import SwiftUI

struct FilePropertyView: View {
    let options: [Property.File.Option]
    let hint: String
    let style: PropertyStyle
    
    var body: some View {
        if options.isNotEmpty {
            if maxOptions > 0 {
                moreObjectsView
            } else {
                objectsList
            }
        } else {
            PropertyValuePlaceholderView(hint: hint, style: style)
        }
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style.objectPropertyStyle.hSpaсingList) {
                ForEach(options) { objectView(option: $0) }
            }
            .padding(.horizontal, 1)
        }
    }
    
    private func objectView(option: Property.File.Option) -> some View {
        HStack(spacing: style.objectPropertyStyle.hSpaсingObject) {
            IconView(icon: option.icon)
                .frame(
                    width: style.objectPropertyStyle.size.width,
                    height: style.objectPropertyStyle.size.height
                )
            
            AnytypeText(
                option.title,
                style: style.font
            )
                .foregroundColor(style.fontColor)
                .lineLimit(1)
        }
    }
    
    private var moreObjectsView: some View {
        let moreObjectsCount = (options.count - maxOptions) > 0 ? options.count - maxOptions : 0

        return HStack(spacing: style.objectPropertyStyle.hSpaсingObject) {
            objectView(options: Array(options.prefix(maxOptions)))

            if moreObjectsCount > 0 {
                CountTagView(count: moreObjectsCount, style: style)
            }
        }
        .padding(.horizontal, 1)
    }
    
    private func objectView(options: [Property.File.Option]) -> some View {
        ForEach(options) { option in
            objectView(option: option)
        }
    }
}

extension FilePropertyView {
    private var maxOptions: Int {
        switch style {
        case .filter, .setCollection, .kanbanHeader, .featuredBlock, .regular: return 1
        case .set: return 0
        }
    }
}


struct FileRelationView_Previews: PreviewProvider {
    static var previews: some View {
        FilePropertyView(options: [], hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
