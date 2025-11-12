import SwiftUI

struct LinkWidgetDefaultHeader<RightView: View>: View {
    
    let title: String
    let titleColor: Color
    let icon: Icon?
    let rightAccessory: RightView
    let onTap: (() -> Void)
    
    init(
        title: String,
        titleColor: Color = .Text.primary,
        icon: Icon?,
        @ViewBuilder rightAccessory: () -> RightView = { EmptyView() },
        onTap: @escaping () -> Void
    ) {
        self.title = title
        self.titleColor = titleColor
        self.icon = icon
        self.rightAccessory = rightAccessory()
        self.onTap = onTap
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if let icon {
                Spacer.fixedWidth(14)
                IconView(icon: icon, assetColor: .Text.primary)
                    .frame(width: 20, height: 20)
                Spacer.fixedWidth(8)
            } else {
                Spacer.fixedWidth(16)
            }
            AnytypeText(title, style: .subheading)
                .foregroundColor(titleColor)
                .lineLimit(1)
                .layoutPriority(-1)
            Spacer.fixedWidth(16)
            Spacer()
            rightAccessory
        }
        .fixTappableArea()
        .onTapGesture {
            onTap()
        }
    }
}
