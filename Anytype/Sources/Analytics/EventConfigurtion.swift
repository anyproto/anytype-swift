//
//  EventConfigurtion.swift
//  Anytype
//
//  Created by Denis Batvinkin on 18.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

struct EventConfigurtion {

    enum EventThreshold {
        case none
        case notInRow // not send same events in a row
    }

    let threshold: EventThreshold
}
