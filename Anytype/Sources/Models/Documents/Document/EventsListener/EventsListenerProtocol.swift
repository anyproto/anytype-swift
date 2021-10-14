//
//  EventsListenerProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 12.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

protocol EventsListenerProtocol: AnyObject {
    
    var onUpdateReceive: ((EventsListenerUpdate) -> Void)? { get set }
    
    func startListening()
    
}
