//
//  TextRelationEditingViewModelDelegate.swift
//  Anytype
//
//  Created by Konstantin Mordan on 25.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

protocol TextRelationEditingViewModelDelegate: AnyObject {
    
    func canOpenUrl(_ url: URL) -> Bool
    func openUrl(_ url: URL)
    
}
