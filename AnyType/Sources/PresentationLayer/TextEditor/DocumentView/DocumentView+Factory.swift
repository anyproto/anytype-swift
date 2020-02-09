//
//  DocumentView+Factory.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension DocumentView {
    private class Holder {
        static let holder = Holder.init()
        var subscriptions: [AnyCancellable?] = []
        func add(_ s: AnyCancellable?) {
            self.subscriptions.append(s)
        }
    }
    static func create(viewModel: DocumentViewModel) -> AnyView {
        let s = viewModel.objectWillChange.sink { (value) in
            print("value: \(value) updated!")
        }
        Holder.holder.add(s)
        if let viewModel = viewModel as? DocumentView.ViewModel {
            return AnyView(DocumentView.ViewControllerContainer(viewModel: viewModel))
        }
        else {
            return AnyView(DocumentView(viewModel: viewModel))
        }
    }
}
