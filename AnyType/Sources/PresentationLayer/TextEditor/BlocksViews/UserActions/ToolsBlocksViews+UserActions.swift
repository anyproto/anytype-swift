//
//  ToolsBlocksViews+UserActions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension ToolsBlocksViews {
    enum UserAction {
        case pageLink
    }
}

extension ToolsBlocksViews.UserAction {
    typealias Id = MiddlewareBlockInformationModel.Id
    enum PageLink {
        case shouldShowPage(Id)
    }
}
