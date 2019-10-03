//
//  DocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct DocumentView: View {
    @ObservedObject var viewModel: DocumentViewModel
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if let blocks = viewModel.documentModel?.blocks {
            if blocks.isEmpty {
                return AnyView(EmptyDocumentView(title: ""))
            } else {
                return AnyView(blocksView(blocks: blocks))
            }
        } else {
          return AnyView(loading)
        }
    }
}

private extension DocumentView {
    
    func blocksView(blocks: [Block]) -> some View {
        return List(blocks) { block in
            TextBlockView()
        }
        .onAppear {
            UITableView.appearance().separatorColor = .clear
        }
        .onDisappear {
            UITableView.appearance().separatorColor = .opaqueSeparator
        }
    }
    
    var loading: some View {
      Text("Loading...")
        .foregroundColor(.gray)
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DocumentViewModel(documentId: nil)
        return DocumentView(viewModel: viewModel)
    }
}
