import SwiftUI
import Combine
import BlocksModels

class HomeViewModel: ObservableObject {
    @ObservedObject var accountData = AccountInfoDataAccessor(profileService: ProfileService())
    
    private var profileViewModelObjectWillChange: AnyCancellable?

    private let homeCollectionViewAssembly: HomeCollectionViewAssembly
    let coordinator = HomeCoordinator(profileAssembly: ProfileAssembly())

    init(homeCollectionViewAssembly: HomeCollectionViewAssembly) {
        self.homeCollectionViewAssembly = homeCollectionViewAssembly
        
        self.profileViewModelObjectWillChange = accountData.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func obtainAccountInfo() {
        self.accountData.obtainAccountInfo()
    }

    // MARK: - View events
    func obtainCollectionView(
        showDocument: Binding<Bool>,
        selectedDocumentId: Binding<String>,
        containerSize: CGSize,
        homeCollectionViewModel: HomeCollectionViewModel,
        cellsModels: Binding<[HomeCollectionViewCellType]>
    ) -> some View {
        self.homeCollectionViewAssembly.createHomeCollectionView(
            showDocument: showDocument, selectedDocumentId: selectedDocumentId, containerSize: containerSize, cellsModels: cellsModels
        ).environmentObject(homeCollectionViewModel)
    }
}
