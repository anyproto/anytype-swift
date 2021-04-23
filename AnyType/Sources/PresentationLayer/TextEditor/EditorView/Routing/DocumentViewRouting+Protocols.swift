//
//  DocumentViewRouting+Protocols.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

/// This protocol provides publisher that is delivering output events to outer world.
/// We could subscribe on this publisher and could receive events.
/// It is necessary for routing purposes.
/// We could subscribe on this publisher in our `UIViewController`, for example.
protocol DocumentViewRoutingOutputProtocol {
    var outputEventsPublisher: AnyPublisher<DocumentViewRouting.OutputEvent, Never> {get}
}

/// This protocol provides `.send` method that is sending events to outer world.
/// However, it is only for `internal` usage, so, you `don't` need to invoke this method directly.
protocol DocumentViewRoutingSendingOutputProtocol {
    func send(event: DocumentViewRouting.OutputEvent)
}
