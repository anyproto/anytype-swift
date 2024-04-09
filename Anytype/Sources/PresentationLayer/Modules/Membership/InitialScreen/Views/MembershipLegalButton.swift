import SwiftUI

struct MembershipLegalButton: View {
    let text: String
    let onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 0) {
                AnytypeText(text, style: .bodyRegular)
                    .foregroundColor(.Text.primary)
                    .lineLimit(1)
                Spacer()
                IconView(icon: .asset(.X18.webLink))
                    .frame(width: 18, height: 18)
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
