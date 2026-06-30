import SwiftUI

struct MembershipLegalButton: View {
    let text: String
    var icon: ImageAsset = .X18.webLink
    var iconSize: CGFloat = 18
    let onTap: () -> ()

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(text, style: .bodyRegular)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)
                Spacer()
                IconView(icon: .asset(icon))
                    .frame(width: iconSize, height: iconSize)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
        }
        .newDivider()
    }
}

#Preview {
    ScrollView {
        VStack {
            MembershipLegalButton(text: "Press me", onTap: {})
            MembershipLegalButton(text: "Press me", onTap: {})
            MembershipLegalButton(text: "Press me", onTap: {})
            MembershipLegalButton(text: "Press me", onTap: {})
        }.padding()
    }
}
