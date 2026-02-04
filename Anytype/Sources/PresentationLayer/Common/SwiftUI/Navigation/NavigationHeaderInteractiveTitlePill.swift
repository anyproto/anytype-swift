import SwiftUI

struct NavigationHeaderInteractiveTitlePill: View {

    let title: String
    let icon: Icon?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 8) {
                if let icon {
                    IconView(icon: icon)
                        .frame(width: 18, height: 18)
                }
                AnytypeText(title, style: .uxTitle1Semibold)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: NavigationHeaderConstants.height)
    }
}
