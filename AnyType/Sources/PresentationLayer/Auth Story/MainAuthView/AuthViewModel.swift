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
	@Published var publicKeys = [String]()
	
	init(publicKeys: [String]? = nil) {
		if let publicKeys = publicKeys {
			self.publicKeys = publicKeys
		}
	}
	
}
