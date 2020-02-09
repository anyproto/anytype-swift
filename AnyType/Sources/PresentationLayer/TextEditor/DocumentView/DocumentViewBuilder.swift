//
//  DocumentViewBuilder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

enum DocumentViewBuilder {
    struct Request {
        var id: String
        var useUIKit: Bool = true
    }
    static func viewModel(by request: Request) -> DocumentViewModel {
        if request.useUIKit {
            return DocumentView.ViewModel(documentId: request.id)
        }
        return DocumentViewModel(documentId: request.id)
    }
    static func documentView(by request: Request) -> some View {
        DocumentView.create(viewModel: self.viewModel(by: request))
    }
}
