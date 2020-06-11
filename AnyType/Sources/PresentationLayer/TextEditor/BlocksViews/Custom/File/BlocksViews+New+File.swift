//
//  BlocksViews+New+File.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension BlocksViews.New.File {
    enum Image {} // -> Image.ContentType.image
    enum Base {}
}

extension BlocksViews.New.File.Base {
    class ViewModel: BlocksViews.New.Base.ViewModel {
        typealias File = BlocksModels.Aliases.BlockContent.File
        typealias State = File.State
        var subscriptions: Set<AnyCancellable> = []
        @Published var state: State? { willSet { self.objectWillChange.send() } }
    }
}
