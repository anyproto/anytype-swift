//
//  BlocksViews.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

enum BlocksViews {
    enum Base {} // Contains Base.ViewModel
    enum Supplement {} // Contains Supplement entries that Serve functionality over ViewModels and Views.
    enum Toolbar {} // Contains Toolbar Views. Possibly that we need another namespace for Views that provides UserActions GUI for BlocksViews.
    enum NewSupplement {} // Contains new implementation of Supplement.
}


extension BlocksViews {
    enum New {}
}

extension BlocksViews.New {
    enum Base {}
    enum Text {}
    enum File {}
    enum Tools {}
    enum Page {}
    enum Bookmark {}
    enum Other {}
    enum Unknown {}
}
