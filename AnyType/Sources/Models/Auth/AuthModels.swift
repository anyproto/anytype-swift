//
//  AuthModels.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation


enum AuthModels {
    enum CreateAccount {}
}

extension AuthModels.CreateAccount {
    
    struct Request {
        var name: String
        var avatar: ProfileModels.Avatar
    }
}
