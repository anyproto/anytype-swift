//
//  ObjectIconImageView.swift
//  ObjectIconImageView
//
//  Created by Konstantin Mordan on 25.08.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import SwiftUI

struct ObjectIconImageView: View {
    
    let objectIconImage: ObjectIconImage
    
    var body: some View {
        switch objectIconImage {
        case .icon:
            EmptyView()
        case .todo:
            EmptyView()
        }
    }
}

struct ObjectIconImageView_Previews: PreviewProvider {
    static var previews: some View {
        ObjectIconImageView(objectIconImage: .todo(false))
    }
}
