import SwiftUI

struct ProfileSectionView: View {
    @ObservedObject var model: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            UserIconView(
                image: self.model.accountData.accountAvatar,
                color: self.model.accountData.visibleSelectedColor,
                name: self.model.accountData.visibleAccountName
            )
            .frame(width: 64, height: 64)
            .padding([.top], 20)

            HStack(spacing: 0) {
                Text(self.model.accountData.visibleAccountName)
                    .font(.title)
                Spacer()
                Image("arrowForward")
            }
            .padding([.top], 11)
            .onTapGesture {
                // TODO: go to profile
            }

            Text("Your public page".localized).foregroundColor(ColorPalette.grayText)
        }
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 9)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}
