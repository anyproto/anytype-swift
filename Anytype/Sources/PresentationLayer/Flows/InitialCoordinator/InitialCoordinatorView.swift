import Foundation
import SwiftUI

struct InitialCoordinatorView: View {
    
    @StateObject var model: InitialCoordinatorViewModel
    
    var body: some View {
        EmptyView()
            .onAppear {
                model.onAppear()
            }
            .alert(Loc.Initial.UnstableMiddle.title, isPresented: $model.showWarningAlert) {
                if UserDefaultsConfig.usersId.isNotEmpty {
                    Button(Loc.Initial.UnstableMiddle.logout) {
                        model.contunueWithLogout()
                    }
                    
                    Button(Loc.Initial.UnstableMiddle.continue, role: .cancel) {
                        model.contunueWithoutLogout()
                    }
                } else {
                    Button(Loc.Initial.UnstableMiddle.wontUseProd) {
                        model.contunueWithoutLogout()
                    }
                }
            } message: {
                Text(Loc.Initial.UnstableMiddle.message)
            }
    }
}
