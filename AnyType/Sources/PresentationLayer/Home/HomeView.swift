import SwiftUI
import Combine

struct HomeView: View {
    // HomeCollectionViewModel here due to SwiftUI doesn't update view when it's UIViewRepresentable
    // https://forums.swift.org/t/uiviewrepresentable-not-updated-when-observed-object-changed/33890/9
    @ObservedObject private var collectionViewModel: HomeCollectionViewModel
    
    @State var showDocument: Bool = false
    @State var selectedDocumentId: String = ""
    @StateObject var accountData = AccountInfoDataAccessor()
    
    private let coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator, collectionViewModel: HomeCollectionViewModel) {
        self.coordinator = coordinator
        self.collectionViewModel = collectionViewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                self.textEditorNavigation
                HomeTopView(accountData: accountData, coordinator: coordinator)
                self.collectionView
            }
            .background(
                LinearGradient(gradient: Gradients.homeBackground, startPoint: .leading, endPoint: .trailing)
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.gray)
        .onAppear(perform: onAppear)
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
            HomeCollectionView(
                viewModel: collectionViewModel,
                showDocument: $showDocument,
                selectedDocumentId: $selectedDocumentId,
                cellsModels: $collectionViewModel.cellViewModels,
                containerSize: geometry.size
            ).padding()
        }
    }
    
    private func onAppear() {
        self.accountData.obtainAccountInfo()
        makeNavigationBarTransparent()
    }
    
    private func makeNavigationBarTransparent() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }
}
