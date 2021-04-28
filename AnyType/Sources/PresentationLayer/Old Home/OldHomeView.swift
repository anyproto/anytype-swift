import SwiftUI
import Combine

struct OldHomeView: View {
    // OldHomeCollectionViewModel here due to SwiftUI doesn't update view when it's UIViewRepresentable
    // https://forums.swift.org/t/uiviewrepresentable-not-updated-when-observed-object-changed/33890/9
    @ObservedObject private var collectionViewModel: OldHomeCollectionViewModel
    
    @State var showDocument: Bool = false
    @State var selectedDocumentId: String = ""
    @StateObject var accountData = AccountInfoDataAccessor()
    
    private let coordinator: OldHomeCoordinator
    
    init(coordinator: OldHomeCoordinator, collectionViewModel: OldHomeCollectionViewModel) {
        self.coordinator = coordinator
        self.collectionViewModel = collectionViewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                self.textEditorNavigation
                OldHomeTopView(accountData: accountData, coordinator: coordinator)
                self.collectionView
            }
            .background(
                LinearGradient(gradient: Gradients.homeBackground, startPoint: .leading, endPoint: .trailing)
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.gray)
        .onAppear(perform: makeNavigationBarTransparent)
        .environmentObject(accountData)
    }
    
    private var textEditorNavigation: some View {
        NavigationLink(
            destination: coordinator.documentView(
                selectedDocumentId: self.selectedDocumentId,
                shouldShowDocument: self.$showDocument
            ).navigationBarHidden(true).edgesIgnoringSafeArea(.all),
            isActive: self.$showDocument,
            label: { EmptyView() }
        )
    }
    
    private var collectionView: some View {
        GeometryReader { geometry in
            OldHomeCollectionView(
                viewModel: collectionViewModel,
                showDocument: $showDocument,
                selectedDocumentId: $selectedDocumentId,
                cellsModels: $collectionViewModel.cellViewModels,
                containerSize: geometry.size
            ).padding()
        }
    }
    
    private func makeNavigationBarTransparent() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }
}
