//
//  HomeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    var user: UserModel = .init()
    func documentView(selectedDocumentId: String) -> some View {
        let viewModel = DocumentViewModel(documentId: selectedDocumentId)
        return DocumentView(viewModel: viewModel)
    }
}

extension HomeViewModel {
    class UserModel {
        var name: String {
            return UserDefaultsConfig.userName.isEmpty ? "Anytype User" : UserDefaultsConfig.userName
        }
    }
}
