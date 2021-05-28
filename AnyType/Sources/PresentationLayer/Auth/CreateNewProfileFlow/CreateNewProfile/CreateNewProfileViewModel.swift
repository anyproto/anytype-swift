import Foundation
import SwiftUI


class CreateNewProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var image: UIImage? = nil
    @Published var disableButton: Bool = true
    
    private var waitingViewOnCreatAccountModel: WaitingViewOnCreatAccountModel
    
    init() {
        waitingViewOnCreatAccountModel = WaitingViewOnCreatAccountModel(userName: "", image: nil)
    }
    
    func showSetupWallet() -> some View {
        waitingViewOnCreatAccountModel.userName = userName
        waitingViewOnCreatAccountModel.image = image
        
        return WaitingViewOnCreatAccount(viewModel: waitingViewOnCreatAccountModel)
    }
}
