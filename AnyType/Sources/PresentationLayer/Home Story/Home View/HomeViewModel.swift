import SwiftUI
import Combine
import BlocksModels

class HomeViewModel: ObservableObject {
    @ObservedObject var accountData = AccountInfoDataAccessor(profileService: ProfileService())
    
    var cachedDocumentView: AnyView?
    var documentViewId: String = ""
    
    
    private var profileViewModelObjectWillChange: AnyCancellable?

    private let homeCollectionViewAssembly: HomeCollectionViewAssembly
    let coordinator = HomeViewCoordinator(profileAssembly: ProfileAssembly())

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
    
    func documentView(selectedDocumentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        if let view = cachedDocumentView, self.documentViewId == selectedDocumentId {
          return view
        }
        
        let view = AnyView(
            self.createDocumentView(documentId: selectedDocumentId, shouldShowDocument: shouldShowDocument)
        )
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }
    
    private func documentView(selectedDocumentId: String) -> some View {
        if let view = cachedDocumentView, self.documentViewId == selectedDocumentId {
          return view
        }
        
        let view: AnyView = .init(self.createDocumentView(documentId: selectedDocumentId))
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }
    
    private func createDocumentView(documentId: String) -> some View {
        EditorModule.TopLevelBuilder.SwiftUIBuilder.documentView(by: .init(id: documentId))
    }
    
    private func createDocumentView(documentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        EditorModule.TopLevelBuilder.SwiftUIBuilder.documentView(
            by: .init(id: documentId), shouldShowDocument: shouldShowDocument
        )
    }
}
