import SwiftUI


struct ProfileSectionView: View {
    @ObservedObject var accountData: AccountInfoDataAccessor
    var coordinator: ProfileCoordinator

    var body: some View {
        NavigationLink(
            destination: coordinator.openProfile(profileId: accountData.profileBlockId ?? "")
        ) {
            VStack(alignment:.leading) {
                UserIconView(
                    image: accountData.accountAvatar,
                    color: accountData.visibleSelectedColor,
                    name: accountData.visibleAccountName
                )
                .frame(width: 64, height: 64)
                .padding([.top], 20)
                HStack(spacing: 0) {
                    Text(accountData.visibleAccountName)
                        .font(.title)
                    Spacer()
                    Image("arrowForward")
                }
                .padding([.top], 11)
                
                Text("Your public page").foregroundColor(Color.grayText)
            }
        }
        .disabled(accountData.profileBlockId == nil)
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 9)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}
