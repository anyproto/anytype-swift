//
//  BlockViewModifieres.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct BaseView: ViewModifier {
    
    func body(content: Content) -> some View {
        HStack {
            Text("+")
            content
        }
    }
   
}
