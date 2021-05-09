import SwiftUI

struct HomeProfileView: View {
    @EnvironmentObject var accountData: AccountInfoDataAccessor
    @EnvironmentObject var model: HomeViewModel
    
    private let topPaddingRatio: CGFloat = 0.16
    
    var body: some View {
        GeometryReader { geometry in
            VStack() {
                Text("Hi, \(accountData.name)")
                    .anyTypeFont(.title)
                    .foregroundColor(.white)
                    .padding(.top, geometry.size.height * topPaddingRatio)
                    .padding(.bottom, 15)
                
                UserIconView(image: accountData.avatar, name: accountData.name)
                    .frame(width: 80, height: 80)
                    .onTapGesture {
                        if let profileBlockId = accountData.blockId {
                            model.showDocument(blockId: profileBlockId)
                        }
                    }

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
                .padding(.top, 40)
                
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
