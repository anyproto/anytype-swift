//
//  HomeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    func documentView(selectedDocumentId: String) -> some View {
        let viewModel = DocumentViewModel(documentId: selectedDocumentId)
        return DocumentView(viewModel: viewModel)
    }
}
