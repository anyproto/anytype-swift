import Foundation
import SwiftUI

class CreateNewProfileViewModel: ObservableObject {
    private let seedService: SeedServiceProtocol

    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }

    func showSetupWallet(signUpData: SignUpData, showWaitingView: Binding<Bool>) -> some View {
        return WaitingOnCreatAccountView(
            viewModel: WaitingOnCreatAccountViewModel(
                signUpData: signUpData,
                showWaitingView: showWaitingView,
                seedService: self.seedService
            )
        )
    }
    
    func setImage(signUpData: SignUpData, itemProvider: NSItemProvider?) {
        guard let itemProvider = itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            DispatchQueue.main.async {
                signUpData.image = image as? UIImage
            }
        }
    }
}
