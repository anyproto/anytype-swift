//
//  HomeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine

struct HomeView: View {
    // TODO: workaround - HomeCollectionView view model here due to SwiftUI doesn't update
    // view when it's UIViewRepresentable
    // https://forums.swift.org/t/uiviewrepresentable-not-updated-when-observed-object-changed/33890/9
    @ObservedObject var collectionViewModel: HomeCollectionViewModel
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
                NavigationLink(
                    destination: self.documentView(hasCustomModalView: false).edgesIgnoringSafeArea(.all),
                    isActive: self.$showDocument,
                    label: { EmptyView() }
                )
                self.topView
                self.collectionView
            }
            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing).edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
        }
        .accentColor(.gray)
        .onAppear(perform: onAppear)
    }

    var topView: some View {
        HStack {
            Text("Hi, \(self.viewModel.profileViewModel.visibleAccountName)")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .font(.title)
            Spacer()
            NavigationLink(destination: self.viewModel.profileViewCoordinator.profileView) {
                UserIconView(
                    image: self.viewModel.profileViewModel.accountAvatar,
                    color: self.viewModel.profileViewModel.visibleSelectedColor,
                    name: self.viewModel.profileViewModel.visibleAccountName
                ).frame(width: 43, height: 43)
            }
        }
        .padding([.top, .trailing, .leading], 20)
    }
    
    var collectionView: some View {
        GeometryReader { geometry in
            self.viewModel.obtainCollectionView(
                showDocument: self.$showDocument,
                selectedDocumentId: self.$selectedDocumentId,
                containerSize: geometry.size,
                homeCollectionViewModel: self.collectionViewModel,
                cellsModels: self.$collectionViewModel.documentsViewModels
            ).padding()
        }
    }
    
    func documentView(hasCustomModalView: Bool = false) -> some View {
        DocumentViewWrapper(viewModel: self.viewModel, selectedDocumentId: self.$selectedDocumentId, shouldShowDocument: self.$showDocument)
    }

    private func onAppear() {
        self.viewModel.obtainAccountInfo()
        HomeView.transparentAppereance()
    }
}

extension HomeView {
    struct DocumentViewWrapper: View {
        @Environment(\.presentationMode) var mode: Binding<PresentationMode>
        @ObservedObject var viewModel: HomeViewModel
        @Binding var selectedDocumentId: String
        @Binding var shouldShowDocument: Bool

        var body: some View {
            self.viewModel.documentView(selectedDocumentId: self.selectedDocumentId, shouldShowDocument: self.$shouldShowDocument)
                .navigationBarHidden(true)
        }
    }
}

extension HomeView {
    // UINavigationBar appearance
    fileprivate static let defautlNavbarImage = UINavigationBar.appearance().backgroundImage(for: .default)

    fileprivate static func transparentAppereance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
