//
//  HomeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    // UINavigationBar appearance
    private let defautlNavbarImage = UINavigationBar.appearance().backgroundImage(for: .default)

    // TODO: workaround - HomeCollectionView view model here due to SwiftUI doesn't update
    // view when it's UIViewRepresentable
    // https://forums.swift.org/t/uiviewrepresentable-not-updated-when-observed-object-changed/33890/9
    @ObservedObject var collectionViewModel: HomeCollectionViewModel
    private var viewModel: HomeViewModel
    
    @State var showDocument: Bool = false
    @State var selectedDocumentId: String = ""
    @State var isNavigationBarHidden: Bool = true // workaround: Used for hiding/show nav bar in childs
    
    init(viewModel: HomeViewModel, collectionViewModel: HomeCollectionViewModel) {
        self.viewModel = viewModel
        self.collectionViewModel = collectionViewModel
    }
    
    var topView: some View {
        HStack {
            Text("Hi, \(self.viewModel.user.name)")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .font(.title)
            Spacer()
            NavigationLink(destination: ProfileViewCoordinator().profileView
                .onAppear {
                    self.isNavigationBarHidden = false
                }
            ) {
                UserIconView(color: .blue, name: viewModel.user.name)
                    .frame(width: 43, height: 43)
            }
        }
        .padding([.top, .trailing, .leading], 20)
    }
    
    var collectionView: some View {
        GeometryReader { geometry in
            self.viewModel.obtainCollectionView(showDocument: self.$showDocument,
                                                selectedDocumentId: self.$selectedDocumentId,
                                                containerSize: geometry.size,
                                                homeCollectionViewModel: self.collectionViewModel,
                                                cellsModels: self.$collectionViewModel.documentsCell)
                .padding()
        }
    }
        
    
    var documentView: some View {
//        NavigationLink(destination:
//            DocomentViewWrapper(viewModel: self.viewModel, selectedDocumentId: self.$selectedDocumentId, isNavigationBarHidden: self.$isNavigationBarHidden),
//                       isActive: self.$showDocument)
//        {
//            return EmptyView()
//        }
//        .frame(width: 0, height: 0)
        DocumentViewWrapper(viewModel: self.viewModel, selectedDocumentId: self.$selectedDocumentId, isNavigationBarHidden: self.$isNavigationBarHidden, shouldShowDocument: self.$showDocument)
    }
    
    var homeView: some View {
        VStack(alignment: .leading, spacing: 0) {
            self.topView
            self.collectionView
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    self.homeView
                    if self.showDocument {
                        self.documentView
                    }
                }
            }
            .background(LinearGradient(gradient: /*@START_MENU_TOKEN@*/Gradient(colors: [Color.red, Color.blue])/*@END_MENU_TOKEN@*/, startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/).edgesIgnoringSafeArea(.all))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(isNavigationBarHidden)
        }
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }

    private func onAppear() {
        isNavigationBarHidden = true
        customAppereance()
    }

    func customAppereance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()

        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = navBarAppearance
    }

    private func onDisappear() {
        UINavigationBar.appearance().setBackgroundImage(defautlNavbarImage, for: .default)
    }
}

/// -- By Sheet or List modal presentation.
/// 1. Add sheet presentation for View.
///
///
///
/// -- Full animation presentation.
/// 1. Add custom transition for view.
/// 2. Enable it by ZStack (?)
/// 3. Or enable it by GeometryReader (?)
/// 4. Add GestureRecognizer to push it down.

extension HomeView {
    struct DocumentViewWrapper: View {
        @ObservedObject var viewModel: HomeViewModel
        @Binding var selectedDocumentId: String
        @Binding var isNavigationBarHidden: Bool
        @Binding var shouldShowDocument: Bool

        @State var dragOffset: CGSize = .zero
        
        var oldBody: some View {
            self.viewModel.documentView(selectedDocumentId: self.selectedDocumentId, shouldShowDocument: self.$shouldShowDocument)
                .navigationBarTitle("") // workaround: used for smooth transition animation
                .navigationBarHidden(isNavigationBarHidden)
                .onAppear {
                    self.isNavigationBarHidden = true
            }
        }
        
        func onDismiss() {
            self.dragOffset = .zero
            self.selectedDocumentId = ""
        }
        
        var body: some View {
            GeometryReader { geometry in
                self.oldBody.animation(.spring())
                    .gesture(
                    DragGesture().onChanged({ (value) in
                        let height = value.translation.height
                        let correctHeight = max(0, height)
                        self.dragOffset = .init(width: self.dragOffset.width, height: correctHeight)
                    }).onEnded({ (value) in
                        let height = value.translation.height
                        if height / geometry.size.height < 0.3 {
                            self.dragOffset = .zero
                        }
                        else {
                            self.shouldShowDocument = false
                            self.onDismiss()
                        }
                    })
                ).offset(self.dragOffset)
            }.transition(.move(edge: .bottom))
        }
    }
}
