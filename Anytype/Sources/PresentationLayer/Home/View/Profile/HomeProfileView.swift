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
                    Spacer.fixedHeight(geometry.size.height * topPaddingRatio)
                    hiText
                    Spacer.fixedHeight(15)
                    avatar
                    Spacer.fixedHeight(geometry.size.height * buttonsPaddingRatio)
                    buttons
                }.frame(maxHeight: geometry.size.height / 2 - 30) // less then bottom sheet
                Spacer()
                slogan(containerHeight: geometry.size.height)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .animation(.default, value: accountData.profileBlockId)
        }
    }
    
    var hiText: some View {
        AnytypeText("Hi, \(accountData.name ?? "")", style: .title, color: .white)
            .padding(.horizontal)
            .transition(.opacity)
    }
    
    private var avatar: some View {
        Group {
            if let blockId = accountData.profileBlockId {
                Button(action: {
                    Amplitude.instance().logEvent(AmplitudeEventsName.profilePage)
                    model.showPage(pageId: blockId)
                }){ userIcon }
            } else {
                userIcon
            }
        }
    }
    
    private var userIcon: some View {
        let iconType: UserIconView.IconType = {
            if let imageId = accountData.avatarId {
                return UserIconView.IconType.image(
                    .middleware(
                        ImageID(id: imageId, width: UserIconView.Constants.size.width.asImageWidth)
                    )
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
            Button(action: {
                model.snackBarData = .init(text: "Store is available in desktop app", showSnackBar: true)
            }) {
                HomeProfileViewButtonImage(
                    image: Image.main.marketplace.renderingMode(.template).foregroundColor(Color.gray.opacity(0.4))
                )
            }
            Button(action: model.createAndShowNewPage) {
                HomeProfileViewButtonImage(image: Image.main.draft)
            }
        }
    }
    
    private func slogan(containerHeight: CGFloat) -> some View {
        Group {
            AnytypeText("The future will be the one you build".localized, style: .title, color: .white)
                .padding()
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            Spacer.fixedHeight(containerHeight / 5)
        }
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
