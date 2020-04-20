//
//  BlocksViews+UserAction+Protocols.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

/// This protocol provides `send()` method that is required for internal needs to publish events.
/// We should adopt this protocol in a view models that would like to tell outer world about events.
/// If events are occured, we need to process them.
/// For receiving events we have distinct protocol.
///
protocol BlocksViewsUserActionsEmittingProtocol {
    func send(userAction: BlocksViews.UserAction)
}

/// This protocol provides publisher that is delivering user actions to outer world.
/// We could subscribe on this publisher and could receive actions.
/// It is necessary for routing purposes.
///
protocol BlocksViewsUserActionsSubscribingProtocol {
    var userActionPublisher: AnyPublisher<BlocksViews.UserAction, Never> {get}
}
