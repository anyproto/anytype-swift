//
//  AuthService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

enum AuthServiceError: Error {
	case logoutError(message: String? = nil)
	case loginError(message: String? = nil)
	case createWalletError(message: String? = nil)
}

protocol AuthService {
	func login(with seed: String) throws
	func logout() throws
	func createWalletAndAccount() throws -> String
}
