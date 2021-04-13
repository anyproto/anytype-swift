import SwiftUI
import Combine

struct HomeView: View {
    // HomeCollectionViewModel here due to SwiftUI doesn't update view when it's UIViewRepresentable
    // https://forums.swift.org/t/uiviewrepresentable-not-updated-when-observed-object-changed/33890/9
    @ObservedObject private var collectionViewModel: HomeCollectionViewModel
    @ObservedObject private var viewModel: HomeViewModel
    
    @State var showDocument: Bool = false
    @State var selectedDocumentId: String = ""
    
    init(viewModel: HomeViewModel, collectionViewModel: HomeCollectionViewModel) {
        self.viewModel = viewModel
        self.collectionViewModel = collectionViewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                self.settingsNavigation
                HomeTopView(accountData: viewModel.accountData, coordinator: viewModel.coordinator)
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
    }
    
    private var settingsNavigation: some View {
        NavigationLink(
            destination: self.viewModel.coordinator.documentView(
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
        self.viewModel.obtainAccountInfo()
        makeNavigationBarTransparent()
    }
    
    private func makeNavigationBarTransparent() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }
}
