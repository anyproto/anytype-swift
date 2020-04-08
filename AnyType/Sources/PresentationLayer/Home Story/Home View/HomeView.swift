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
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink(destination:
                    DocomentViewWrapper(viewModel: self.viewModel, selectedDocumentId: self.$selectedDocumentId, isNavigationBarHidden: self.$isNavigationBarHidden),
                               isActive: self.$showDocument)
                {
                    return EmptyView()
                }
                .frame(width: 0, height: 0)

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
                
                GeometryReader { geometry in
                    self.viewModel.obtainCollectionView(showDocument: self.$showDocument,
                                                        selectedDocumentId: self.$selectedDocumentId,
                                                        containerSize: geometry.size,
                                                        homeCollectionViewModel: self.collectionViewModel,
                                                        cellsModels: self.$collectionViewModel.documentsCell)
                        .padding()
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

struct DocomentViewWrapper: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var selectedDocumentId: String
    @Binding var isNavigationBarHidden: Bool

    var body: some View {
        self.viewModel.documentView(selectedDocumentId: self.selectedDocumentId)
            .navigationBarTitle("") // workaround: used for smooth transition animation
            .navigationBarHidden(isNavigationBarHidden)
            .onAppear {
                self.isNavigationBarHidden = true
            }
    }
}
