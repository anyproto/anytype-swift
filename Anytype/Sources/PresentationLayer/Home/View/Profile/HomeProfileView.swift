import SwiftUI
import Amplitude


struct HomeProfileView: View {
    @EnvironmentObject var accountData: AccountInfoDataAccessor
    @EnvironmentObject var model: HomeViewModel
    
    private let topPaddingRatio: CGFloat = 0.16
    private let buttonsPaddingRatio: CGFloat = 0.05
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    hiText(containerHeight: geometry.size.height)
                        .padding(.top, geometry.size.height * topPaddingRatio)
                        .padding(.bottom, 15)
                    avatar
                        .padding(.bottom, geometry.size.height * buttonsPaddingRatio)
                    buttons
                }.frame(maxHeight: geometry.size.height / 2 - 30) // less then bottom sheet
                Spacer()
                slogan(containerHeight: geometry.size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.default, value: accountData.profileBlockId)
        }
    }
    
    func hiText(containerHeight: CGFloat) -> some View {
        AnytypeText("Hi, \(accountData.name ?? "")", style: .title, color: .white)
            .padding(.horizontal)
            .transition(.opacity)
    }
    
    private var avatar: some View {
        Group {
            if let blockId = accountData.profileBlockId {
                NavigationLink(
                    destination: model.coordinator.documentView(selectedDocumentId: blockId).onAppear {
                        // Analytics
                        Amplitude.instance().logEvent(AmplitudeEventsName.profilePage)
                    },
                    label: { userIcon }
                )
            } else {
                userIcon
            }
        }
    }
    
    private var userIcon: some View {
        let iconType: UserIconView.IconType = {
            if let imageId = accountData.avatarId {
                return UserIconView.IconType.image(
                    .middleware(ImageID(id: imageId))
                )
            } else if let firstCharacter = accountData.name?.first {
                return UserIconView.IconType.placeholder(firstCharacter)
            } else {
                return UserIconView.IconType.placeholder(nil)
            }
        }()
        
        return UserIconView(icon: iconType)
    }
    
    private var buttons: some View {
        HStack(spacing: 20) {
            Button(action: model.startSearch) {
                HomeProfileViewButtonImage(image: Image.main.search)
            }
            Button(action: {}) {
                HomeProfileViewButtonImage(
                    image: Image.main.marketplace.renderingMode(.template).foregroundColor(Color.gray.opacity(0.4))
                )
            }.disabled(true)
            Button(action: model.createNewPage) {
                HomeProfileViewButtonImage(image: Image.main.draft)
            }
        }
    }
    
    private func slogan(containerHeight: CGFloat) -> some View {
        AnytypeText("The future will be the one you build", style: .title, color: .white)
            .padding(.bottom, containerHeight / 6)
            .padding()
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct HomeProfileView_Previews: PreviewProvider {
    static var previews: some View {
        HomeProfileView()
            .environmentObject(AccountInfoDataAccessor())
            .environmentObject(HomeViewModel())
            .background(Color.pureBlue)
    }
}
