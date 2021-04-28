import SwiftUI


struct ProfileSectionView: View {
    @EnvironmentObject private var model: ProfileViewModel

    var body: some View {
        NavigationLink(
            destination: model.coordinator.openProfile(profileId: model.accountData.profileBlockId ?? "")
        ) {
            VStack(alignment:.leading) {
                UserIconView(
                    image: model.accountData.accountAvatar,
                    color: model.accountData.visibleSelectedColor,
                    name: model.accountData.visibleAccountName
                )
                .frame(width: 64, height: 64)
                .padding([.top], 20)
                HStack(spacing: 0) {
                    Text(model.accountData.visibleAccountName)
                        .font(.title)
                    Spacer()
                    Image("arrowForward")
                }
                .padding([.top], 11)
                
                Text("Your public page").foregroundColor(Color.grayText)
            }
        }
        .disabled(model.accountData.profileBlockId == nil)
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 9)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}
