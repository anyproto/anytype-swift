import SwiftUI


struct ProfileSectionView: View {
    @EnvironmentObject private var model: ProfileViewModel
    @EnvironmentObject private var accountData: AccountInfoDataAccessor
    @State private var showingDocument: Bool = false

    var body: some View {
        NavigationLink(
            destination: model.coordinator.openProfile(
                profileId: accountData.blockId ?? "",
                shouldShowDocument: $showingDocument
            ).navigationBarHidden(true).edgesIgnoringSafeArea(.all),
            isActive: $showingDocument
        ) {
            VStack(alignment:.leading) {
                UserIconView(
                    image: accountData.avatar,
                    name: accountData.name
                )
                .frame(width: 64, height: 64)
                .padding([.top], 20)
                HStack(spacing: 0) {
                    Text(accountData.name)
                        .font(.title).foregroundColor(.black)
                    Spacer()
                    Image("arrowForward")
                }
                .padding([.top], 11)
                
                Text("Your public page").foregroundColor(Color.grayText)
            }
        }
        .disabled(accountData.blockId == nil)
        .padding([.leading, .trailing], 20)
        .padding(.bottom, 9)
        .background(Color.white)
        .cornerRadius(12.0)
    }
}
