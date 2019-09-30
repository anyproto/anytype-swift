//
//  AuthViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 21.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    private var textileService = TextileAuthService()
    
    @Published var publicKeys = Array(UserDefaultsConfig.usersPublicKey).sorted() {
        didSet {
            let usersPublicKeyRemoved = Array(Set(oldValue).subtracting(Set(publicKeys)))
            
            for key in usersPublicKeyRemoved {
                do {
                    try textileService.removeAccount(publicKey: key)
                } catch {
                    publicKeys = oldValue
                }
            }
        }
    }
}
