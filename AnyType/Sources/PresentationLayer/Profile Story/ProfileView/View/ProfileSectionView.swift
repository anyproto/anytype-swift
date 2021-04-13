import SwiftUI

struct ProfileSectionView: View {
    @ObservedObject var accountData: AccountInfoDataAccessor
    var coordinator: ProfileCoordinator

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
            .onTapGesture {
//                coordinator.showProfile()
            }

            Text("Your public page").foregroundColor(ColorPalette.grayText)
        }
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 9)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}
