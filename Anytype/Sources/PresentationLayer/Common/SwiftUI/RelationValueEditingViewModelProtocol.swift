//
//  RelationValueEditingViewModelProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import SwiftUI

protocol RelationValueEditingViewModelProtocol: View {
    
    var title: String { get }
    
    func saveValue()
    
}
