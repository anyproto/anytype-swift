//
//  StoreService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11/07/2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

/// Протокол для работы со стором
protocol StoreServiceProtocol {
    var jwtAccessToken: String? { get set }
    var jwtRefreshToken: String? { get set }
    var fireBaseToken: String? { get set }
    var pinCode: String? { get set }
}

/// Класс реализует протокол для работы со стором
class StoreService: StoreServiceProtocol {
    static let shared = StoreService()
    private let keychainService = KeychainService.shared
    
    // MARK: - Lifecycle
    
    private init() {
    }
    
    
    // MARK: - Public properties
    
    var jwtRefreshToken: String? {
        get {
            return keychainService.retreiveItem(itemLabel: .JWTRefreshTokenLabel)
        }
        set {
            if let newValue = newValue {
                keychainService.storeGeneralItem(token: newValue, itemLabel: .JWTRefreshTokenLabel)
            } else {
                keychainService.removeItem(itemLabel: .JWTRefreshTokenLabel)
            }
        }
    }
    
    var fireBaseToken: String? {
        get {
            return keychainService.retreiveItem(itemLabel: .FireBaseTokenLabel)
        }
        set {
            if let newValue = newValue {
                keychainService.storeGeneralItem(token: newValue, itemLabel: .FireBaseTokenLabel)
            } else {
                keychainService.removeItem(itemLabel: .FireBaseTokenLabel)
            }
        }
    }
    
    var pinCode: String? {
        get {
            return keychainService.retreiveItem(itemLabel: .PINCodeLabel)
        }
        set {
            if let newValue = newValue {
                keychainService.storeGeneralItem(token: newValue, itemLabel: .PINCodeLabel)
            } else {
                keychainService.removeItem(itemLabel: .PINCodeLabel)
            }
        }
    }
    
    var jwtAccessToken: String? {
        get {
            return keychainService.retreiveItem(itemLabel: .JWTAccessTokenLabel)
        }
        set {
            if let newValue = newValue {
                keychainService.storeGeneralItem(token: newValue, itemLabel: .JWTAccessTokenLabel)
            } else {
                keychainService.removeItem(itemLabel: .JWTAccessTokenLabel)
            }
        }
    }
}
