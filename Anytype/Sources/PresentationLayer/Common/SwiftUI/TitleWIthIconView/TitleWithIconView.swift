import SwiftUI
import AnytypeCore

struct TitleWithIconView: View {
    let icon: Icon?
    let showIcon: Bool
    let canEditIcon: Bool
    let title: String?
    let showTitle: Bool
    let style: TitleWithIconStyle

    var body: some View {
        titleWithIcon
    }
    
    @ViewBuilder
    private var titleWithIcon: some View {
        if let icon = icon, showIcon {
            ZStack(alignment: .topLeading) {
                title(with: title?.leftIndented)
                IconView(icon: icon)
                .frame(
                    width: style.iconSize.width,
                    height: style.iconSize.height
                )
                .padding(.top, 1)
                .disabled(!canEditIcon)
            }
        } else {
            title(with: title)
        }
    }
    
    @ViewBuilder
    private func title(with text: String?) -> some View {
        if showTitle, let text = text, text.isNotEmpty {
            AnytypeText(text, style: style.titleFont)
            .foregroundColor(.Text.primary)
                .lineLimit(style.lineLimit)
                .multilineTextAlignment(.leading)
        } else {
            EmptyView()
        }
    }
}

struct TitleWithIconView_Previews: PreviewProvider {
    static var previews: some View {
        TitleWithIconView(
            icon: .object(.emoji(Emoji("📘")!)),
            showIcon: true, 
            canEditIcon: true,
            title: "Let's see how this TitleWithIconView looks like with image - header style",
            showTitle: true,
            style: .header
        )
        .previewLayout(.fixed(width: 375, height: 150))
        
        TitleWithIconView(
            icon: .object(.emoji(Emoji("📘")!)),
            showIcon: true,
            canEditIcon: true,
            title: "Let's see how this TitleWithIconView looks like with image - list style",
            showTitle: true,
            style: .list
        )
        .previewLayout(.fixed(width: 375, height: 150))
        
        TitleWithIconView(
            icon: .object(.emoji(Emoji("📘")!)),
            showIcon: true,
            canEditIcon: true,
            title: "Let's see how this TitleWithIconView looks like with image - gallery style",
            showTitle: false,
            style: .gallery
        )
        .previewLayout(.fixed(width: 375, height: 150))
    }
}

