import SwiftUI

struct OldHomeTopView: View {
    @ObservedObject var accountData: AccountInfoDataAccessor
    var coordinator: OldHomeCoordinator
    
    var body: some View {
        HStack {
            Text("Hi, \(accountData.name)")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .font(.title)
            Spacer()
            NavigationLink(destination: coordinator.profileView()) {
                UserIconView(
                    image: accountData.avatar,
                    name: accountData.name
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
            coordinator: OldHomeCoordinator(
                profileAssembly: ProfileAssembly(),
                editorAssembly: EditorAssembly()
            )
        )
    }
}
