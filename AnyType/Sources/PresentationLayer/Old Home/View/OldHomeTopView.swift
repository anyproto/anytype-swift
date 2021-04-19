import SwiftUI

struct OldHomeTopView: View {
    @ObservedObject var accountData: AccountInfoDataAccessor
    var coordinator: OdlHomeCoordinator
    
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
    static var previews: some View {
        OldHomeTopView(
            accountData: AccountInfoDataAccessor(),
            coordinator: OdlHomeCoordinator(
                profileAssembly: ProfileAssembly(),
                editorAssembly: EditorAssembly()
            )
        )
    }
}
