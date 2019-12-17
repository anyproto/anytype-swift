//
//  ProfileModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit
import SwiftUI


struct ProfileModel {
    @Environment(\.localRepoService) var localRepoService
    let profiles: [ProfileModel]
    
    enum Avatar {
        case color(String)
        case imagePath(String)
    }
    
    struct Profile: Identifiable {
        var id: String
        var name: String
        var avatar: Avatar
        var peers: String? = nil
        var uploaded: Bool
    }
}
