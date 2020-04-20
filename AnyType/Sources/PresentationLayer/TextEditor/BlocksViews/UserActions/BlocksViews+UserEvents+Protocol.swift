//
//  BlocksViews+UserEvents+Protocol.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

/// This protocol provides `receive()` method that will handle incoming events.
/// You could catch them in `blockViewsModels` subclasses and react appropriately.
///
protocol BlocksViewsUserActionsReceivingProtocol {
    func receive(event: BlocksViews.UserEvent)
}
