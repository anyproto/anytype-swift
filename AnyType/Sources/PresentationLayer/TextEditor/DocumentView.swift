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
        if let builders = viewModel.blocksViewsBuilders {
            if builders.isEmpty {
                return AnyView(EmptyDocumentView(title: ""))
            } else {
                return AnyView(blocksView(viewBulders: builders))
            }
        } else {
          return AnyView(loading)
        }
    }
}

private extension DocumentView {
    
    func blocksView(viewBulders: [BlockViewRowBuilderProtocol]) -> some View {
        return List(viewBulders, id: \.id) { rowViewBuilder in
            rowViewBuilder.buildView()
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
        let viewModel = DocumentViewModel(documentId: "1")
        
        return DocumentView(viewModel: viewModel)
    }
}
