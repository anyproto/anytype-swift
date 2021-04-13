import SwiftUI

struct HomeTopView: View {
    @ObservedObject var accountData: AccountInfoDataAccessor
    var coordinator: HomeCoordinator
    
    var body: some View {
        HStack {
            Text("Hi, \(accountData.visibleAccountName)")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .font(.title)
            Spacer()
            NavigationLink(destination: coordinator.profileView()) {
                UserIconView(
                    image: accountData.accountAvatar,
                    color: accountData.visibleSelectedColor,
                    name: accountData.visibleAccountName
                ).frame(width: 43, height: 43)
            }
        }
        .padding([.top, .trailing, .leading], 20)
    }
}

import Combine
struct TopView_Previews: PreviewProvider {
    class ProfileServiceMock: ProfileServiceProtocol {
        var name: String? = "UserName"
        
        var avatar: String? = "Avatar"
        
        func obtainUserInformation() -> AnyPublisher<ServiceSuccess, Error> {
            return .empty()
        }
    }
    
    static var previews: some View {
        HomeTopView(
            accountData: AccountInfoDataAccessor(
                profileService: ProfileServiceMock()
            ),
            coordinator: HomeCoordinator(
                profileAssembly: ProfileAssembly()
            )
        )
    }
}
