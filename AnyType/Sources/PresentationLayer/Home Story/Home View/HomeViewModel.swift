//
//  HomeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    
    var documentView: some View {
        let viewModel = DocumentViewModel(documentId: nil)
        return DocumentView(viewModel: viewModel)
    }
}
