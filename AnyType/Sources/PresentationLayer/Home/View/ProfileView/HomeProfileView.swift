import SwiftUI

struct HomeProfileView: View {
    @EnvironmentObject var accountData: AccountInfoDataAccessor
    @EnvironmentObject var model: HomeViewModel
    
    private let topPaddingRatio: CGFloat = 0.16
    private let buttonsPaddingRatio: CGFloat = 0.05
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                VStack {
                    AnytypeText("Hi, \(accountData.name)", style: .title)
                        .foregroundColor(.white)
                        .padding(.top, geometry.size.height * topPaddingRatio)
                        .padding(.bottom, 15)
                    
                    NavigationLink(
                        destination: model.coordinator.documentView(
                            selectedDocumentId: accountData.blockId ?? ""
                        ),
                        label: {
                            UserIconView(image: accountData.avatar, name: accountData.name)
                                .frame(width: 80, height: 80)
                        }
                    ).disabled(accountData.blockId.isNil)
                    
                    HStack {
                        Button(action: {}) {
                            HomeProfileViewButtonImage(image: Image.main.search)
                        }
                        Button(action: {}) {
                            HomeProfileViewButtonImage(image: Image.main.marketplace).padding(10)
                        }
                        Button(action: model.createNewPage) {
                            HomeProfileViewButtonImage(image: Image.main.draft)
                        }
                    }
                    .padding(.top, geometry.size.height * buttonsPaddingRatio)
                }.frame(maxHeight: geometry.size.height / 2 - 30) // less then bottom sheet
                Spacer()
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct HomeProfileView_Previews: PreviewProvider {
    static var previews: some View {
        HomeProfileView()
    }
}
