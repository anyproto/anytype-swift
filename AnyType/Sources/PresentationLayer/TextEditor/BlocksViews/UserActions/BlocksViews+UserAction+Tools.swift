//
//  BlocksViews+UserAction+Tools.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = BlocksViews.UserAction

extension Namespace {
    enum Tools {}
}

extension Namespace.Tools {
    enum UserAction {
        case pageLink(PageLink)
    }
}

extension Namespace.Tools.UserAction {
    typealias Id = String
    enum PageLink {
        case shouldShowPage(Id)
    }
}
