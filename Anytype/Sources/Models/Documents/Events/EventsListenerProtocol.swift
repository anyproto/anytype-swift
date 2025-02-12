//
//  EventsListenerProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 12.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

protocol EventsListenerProtocol: AnyObject {
    
    func setOnUpdateReceice(_ closure: @escaping @Sendable ([DocumentUpdate]) -> Void)
    
    func startListening()
    
    func stopListening()
}
