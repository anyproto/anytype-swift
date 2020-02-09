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
    // TODO: Remove later.
    // It is nice exapmle of using UIViewControllerRepresentable.
    // Update controller not called. Ha.ha.ha.
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
            return .init(DocumentView.ViewControllerContainer(viewModel: viewModel))
        }
        else {
            return .init(DocumentView(viewModel: viewModel))
        }
    }
}
