//
//  HomeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    @Environment(\.developerOptions) private var developerOptions
    var user: UserModel = .init()
    
    func documentView(selectedDocumentId: String) -> some View {
        DocumentViewBuilder.documentView(by: .init(id: selectedDocumentId, useUIKit: self.developerOptions.current.workflow.mainDocumentEditor.useUIKit))
    }
}

extension HomeViewModel {
    class UserModel {
        var name: String {
            return UserDefaultsConfig.userName.isEmpty ? "Anytype User" : UserDefaultsConfig.userName
        }
    }
}
