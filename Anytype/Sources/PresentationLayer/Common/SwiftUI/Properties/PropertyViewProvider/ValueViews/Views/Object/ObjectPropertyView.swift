import SwiftUI
import AnytypeCore

struct ObjectPropertyView: View {
    let options: [Property.Object.Option]
    let hint: String
    let style: PropertyStyle
    
    var body: some View {
        if let links = style.links {
            let title = links.title(with: options.count)
            linksView(with: title)
        } else if options.isEmpty {
            PropertyValuePlaceholderView(hint: hint, style: style)
        } else if maxOptions > 0 {
            moreObjectsView
        } else {
            objectsList
        }
    }
    
    private func linksView(with title: String) -> some View {
        AnytypeText(
            title,
            style: style.font
        )
        .foregroundColor(.Text.secondary)
        .lineLimit(1)
    }
    
    private var objectsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: style.objectPropertyStyle.hSpaсingList) {
                ForEach(options) { option in
                    objectView(option: option)
                }
            }.padding(.horizontal, 1)
        }
    }
    
    private func objectView(option: Property.Object.Option) -> some View {
        HStack(spacing: style.objectPropertyStyle.hSpaсingObject) {
            
            if let icon = option.icon, shouldShowIcon(icon: icon) {
                IconView(icon: icon)
                    .frame(
                        width: style.objectPropertyStyle.size.width,
                        height: style.objectPropertyStyle.size.height
                    )
                    .allowsHitTesting(false)
            }
            
            AnytypeText(
                option.title,
                style: style.font
            )
            .foregroundColor(titleColor(option: option))
            .lineLimit(1)
        }
    }
    
    private var moreObjectsView: some View {
        let moreObjectsCount = (options.count - maxOptions) > 0 ? options.count - maxOptions : 0
        
        return HStack(spacing: style.objectPropertyStyle.hSpaсingObject) {
            if let prefix {
                AnytypeText(
                    prefix,
                    style: style.font
                )
                .foregroundColor(style.fontColorWithError)
            }

            objectView(options: Array(options.prefix(maxOptions)))

            if moreObjectsCount > 0 {
                CountTagView(count: moreObjectsCount, style: style)
            }
        }
        .padding(.horizontal, 1)
    }
    
    private func objectView(options: [Property.Object.Option]) -> some View {
        ForEach(options) { option in
            objectView(option: option)
        }
    }
    
    private func titleColor(option: Property.Object.Option) -> Color {
        if style.isError {
            return style.fontColorWithError
        } else if option.isDeleted || option.isArchived {
            return .Text.tertiary
        } else {
            return style.fontColor
        }
    }
    
    private func shouldShowIcon(icon: Icon) -> Bool {
        switch style {
        case .regular, .set, .filter, .setCollection, .kanbanHeader:
            return true
        case .featuredBlock(let settings):
            return settings.showIcon
        }
    }
}

extension ObjectPropertyView {
    struct ObjectPropertyStyle {
        let hSpaсingList: CGFloat
        let hSpaсingObject: CGFloat
        let size: CGSize
    }
    
    private var maxOptions: Int {
        switch style {
        case .filter, .setCollection, .featuredBlock, .kanbanHeader, .regular: return 1
        case .set: return 0
        }
    }
    
    private var prefix: String? {
        switch style {
        case .regular, .set, .filter, .setCollection, .kanbanHeader:
            return nil
        case .featuredBlock(let settings):
            return settings.prefix
        }
    }
}


struct ObjectRelationView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectPropertyView(options: [], hint: "Hint", style: .regular(allowMultiLine: false))
    }
}
