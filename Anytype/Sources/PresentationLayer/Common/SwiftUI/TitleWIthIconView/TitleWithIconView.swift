import SwiftUI
import AnytypeCore

struct TitleWithIconView: View {
    let icon: Icon?
    let showIcon: Bool
    let title: String?
    let style: TitleWithIconStyle
    @EquatableNoop var onIconTap: () -> Void

    var body: some View {
        titleWithIcon
    }
    
    private var titleWithIcon: some View {
        Group {
            if let icon = icon, showIcon{
                ZStack(alignment: .topLeading) {
                    title(with: title?.leftIndented)
                    IconView(icon: icon)
                    .frame(
                        width: style.iconSize.width,
                        height: style.iconSize.height
                    )
                    .padding(.top, 1)
                    .onTapGesture {
                        onIconTap()
                    }
                }
            } else {
                title(with: title)
            }
        }
    }
    
    private func title(with text: String?) -> some View {
        Group {
            if let text = text, text.isNotEmpty {
                AnytypeText(text, style: style.titleFont)
                .foregroundColor(.Text.primary)
                    .lineLimit(style.lineLimit)
                    .multilineTextAlignment(.leading)
            } else {
                EmptyView()
            }
        }
    }
}

struct TitleWithIconView_Previews: PreviewProvider {
    static var previews: some View {
        TitleWithIconView(
            icon: .object(.emoji(Emoji("📘")!)),
            showIcon: true,
            title: "Let's see how this TitleWithIconView looks like with image - header style",
            style: .header,
            onIconTap: {}
        )
        .previewLayout(.fixed(width: 375, height: 150))
        
        TitleWithIconView(
            icon: .object(.emoji(Emoji("📘")!)),
            showIcon: true,
            title: "Let's see how this TitleWithIconView looks like with image - list style",
            style: .list,
            onIconTap: {}
        )
        .previewLayout(.fixed(width: 375, height: 150))
        
        TitleWithIconView(
            icon: .object(.emoji(Emoji("📘")!)),
            showIcon: true,
            title: "Let's see how this TitleWithIconView looks like with image - gallery style",
            style: .gallery,
            onIconTap: {}
        )
        .previewLayout(.fixed(width: 375, height: 150))
    }
}

