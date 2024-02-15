import Foundation
import SwiftUI

struct InviteLinkView: View {
    
    let invite: String
    let left: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                AnytypeText("Invite link", style: .uxTitle1Semibold, color: .Text.primary)
                Spacer()
                IconView(icon: .asset(.X24.replace))
                    .frame(width: 28, height: 28)
            }
            Spacer.fixedHeight(8)
            AnytypeText("Send this link to invite others. Assign access rights upon their request approval", style: .uxCalloutRegular, color: .Text.primary)
            Spacer.fixedHeight(8)
            AnytypeText(invite, style: .uxCalloutRegular, color: .Text.secondary)
                .frame(height: 48)
                .newDivider()
            Spacer.fixedHeight(14)
            AnytypeText("You can add \(left) more members", style: .relation3Regular, color: .secondary)
                .lineLimit(1)
                .fixedSize(horizontal: false, vertical: true)
            Spacer.fixedHeight(13)
            StandardButton("Share invite link", style: .primaryLarge) {
                print("tap")
            }
        }
        .padding(20)
        .background(Color.Background.secondary)
        .cornerRadius(16, style: .continuous)
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
        .shadow(radius: 16)
        .ignoresSafeArea()
    }
}
