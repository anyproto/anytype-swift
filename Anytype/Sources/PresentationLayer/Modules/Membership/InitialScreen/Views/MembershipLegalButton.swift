import SwiftUI

struct MembershipLegalButton: View {
    let text: String
    let onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(text, style: .bodyRegular, color: .Text.primary)
                    .lineLimit(1)
                Spacer()
                IconView(icon: .asset(.X18.help))
                    .frame(width: 16, height: 16)
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
