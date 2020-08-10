//
//  HomeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine
import BlocksModels

class HomeViewModel: ObservableObject {
    @Environment(\.developerOptions) private var developerOptions
    var homeCollectionViewAssembly: HomeCollectionViewAssembly
    var profileViewCoordinator: ProfileViewCoordinator
    var user: UserModel = .init()
    var cachedDocumentView: AnyView?
    var documentViewId: String = ""

    init(homeCollectionViewAssembly: HomeCollectionViewAssembly, profileViewCoordinator: ProfileViewCoordinator) {
        self.homeCollectionViewAssembly = homeCollectionViewAssembly
        self.profileViewCoordinator = profileViewCoordinator
        self.user.configured(namePublisher: self.profileViewCoordinator.viewModel.$accountName.eraseToAnyPublisher())
    }
    
    func createDocumentView(documentId: String) -> some View {
//        DocumentModule.DocumentViewBuilder.SwiftUIBuilder.documentView(by: .init(id: documentId))
        DocumentModule.TopLevelBuilder.SwiftUIBuilder.documentView(by: .init(id: documentId))
        /// TODO: Remove when you can.
        /// It is old DocumentViewBuilder.
        /// Lets keep it until we remove it from project.
//        DocumentViewBuilder.SwiftUIBuilder.documentView(by: .init(id: documentId, useUIKit: self.developerOptions.current.workflow.mainDocumentEditor.useUIKit))
    }
    
    func createDocumentView(documentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        DocumentModule.TopLevelBuilder.SwiftUIBuilder.documentView(by: .init(id: documentId), shouldShowDocument: shouldShowDocument)
    }
    
    func documentView(selectedDocumentId: String) -> some View {
        if let view = cachedDocumentView, self.documentViewId == selectedDocumentId {
          return view
        }
        
        let view: AnyView = .init(self.createDocumentView(documentId: selectedDocumentId))
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }
    
    func documentView(selectedDocumentId: String, shouldShowDocument: Binding<Bool>) -> some View {
        if let view = cachedDocumentView, self.documentViewId == selectedDocumentId {
          return view
        }
        
        let view: AnyView = .init(self.createDocumentView(documentId: selectedDocumentId, shouldShowDocument: shouldShowDocument))
        self.documentViewId = selectedDocumentId
        cachedDocumentView = view
        
        return view
    }
}

// MARK: AccountInfo
extension HomeViewModel {
    func obtainAccountInfo() {
        self.profileViewCoordinator.viewModel.obtainAccountInfo()
    }
}

// MARK: UserModel
extension HomeViewModel {
    class UserModel: ObservableObject {
        struct Resource {
            var namePlaceholder: String = "Anytype User"
        }
        var resource: Resource = .init()
        
        /// Properties
        var name: String {
            guard let name = self.namePublished, !name.isEmpty else { return self.resource.namePlaceholder }
            return name
        }
        
        /// Private properties
        @Published private var namePublished: String?
        private var nameSubscription: AnyCancellable?
        
        func configured(namePublisher: AnyPublisher<String, Never>) {
            self.nameSubscription = namePublisher.sink { [weak self] (value) in
                self?.namePublished = value
            }
        }
    }
}

// MARK: - View events

extension HomeViewModel {
    func obtainCollectionView(showDocument: Binding<Bool>,
                              selectedDocumentId: Binding<String>,
                              containerSize: CGSize,
                              homeCollectionViewModel: HomeCollectionViewModel,
                              cellsModels: Binding<[HomeCollectionViewCellType]>) -> some View {
        self.homeCollectionViewAssembly.createHomeCollectionView(showDocument: showDocument, selectedDocumentId: selectedDocumentId, containerSize: containerSize, cellsModels: cellsModels).environmentObject(homeCollectionViewModel)
    }
}
