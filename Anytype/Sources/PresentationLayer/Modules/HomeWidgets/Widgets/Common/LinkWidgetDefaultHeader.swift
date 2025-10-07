import SwiftUI

struct LinkWidgetDefaultHeader<RightView: View>: View {
    
    let title: String
    let icon: Icon?
    let rightAccessory: RightView
    let onTap: (() -> Void)
    
    init(
        title: String,
        icon: Icon?,
        @ViewBuilder rightAccessory: () -> RightView = { EmptyView() },
        onTap: @escaping () -> Void
    ) {
        self.title = title
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
                .foregroundColor(.Text.primary)
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
