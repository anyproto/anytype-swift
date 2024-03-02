import SwiftUI

struct MembershipTeirView: View {
    let title: String = "Explorer"
    let subtitle: String = "Dive into the network and enjoy the thrill of one-on-one collaboration"
    let gradient: FadingGradient = .green
    let onTap: () -> () = { }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(16)
            Image(asset: .Membership.tierExplorer)
                .frame(width: 65, height: 64)
            Spacer.fixedHeight(10)
            AnytypeText(title, style: .bodySemibold, color: .Text.primary)
            Spacer.fixedHeight(5)
            AnytypeText(subtitle, style: .caption1Regular, color: .Text.primary)
            Spacer()
            
            info
            Spacer.fixedHeight(10)
            StandardButton("Learn more", style: .primaryMedium, action: onTap)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 16)
        .frame(width: 192, height: 296)
        .background(gradient)
        .cornerRadius(16, style: .continuous)
    }
    
    var info: some View {
        AnytypeText("Just e-mail", style: .bodySemibold, color: .Text.primary)
    }
}

#Preview {
    ScrollView(.horizontal) {
        HStack {
            MembershipTeirView()
            MembershipTeirView()
            MembershipTeirView()
        }
    }.padding()
}
