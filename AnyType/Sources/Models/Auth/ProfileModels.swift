//
//  ProfileModels.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit


enum ProfileModels {
    enum Avatar {
        case color(String)
        case imagePath(String)
    }
    
    struct Profile {
        var id: String
        var name: String
        var avatar: Avatar
    }
}
