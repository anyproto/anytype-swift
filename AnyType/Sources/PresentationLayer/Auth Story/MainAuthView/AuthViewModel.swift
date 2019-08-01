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
	let willChange = PassthroughSubject<AuthViewModel, Never>()
	
	var publicKeys = [String]() {
		willSet {
			willChange.send(self)
		}
	}
	
	init(publicKeys: [String]? = nil) {
		if let publicKeys = publicKeys {
			self.publicKeys = publicKeys
		}
	}
}
