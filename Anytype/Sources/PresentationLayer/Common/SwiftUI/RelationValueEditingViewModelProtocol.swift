//
//  RelationValueEditingViewModelProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

protocol RelationValueEditingViewModelProtocol {
    
    var title: String { get }
    
    func saveValue()
    
}
