//
//  ProfileViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import SwiftUI
import Textile

final class ProfileViewModel: ObservableObject {
	let willChange = PassthroughSubject<ProfileViewModel, Never>()
	
	var accountName: String = "" {
		willSet {
			willChange.send(self)
		}
	}
	
	init() {
		obtainAccountName()
	}
	
	private func obtainAccountName() {
		var error: NSError?
		let profile = Textile.instance().profile.get(&error)
		if (error != nil) {
			// Do something with this error
		} else {
			accountName = profile.name
		}
	}
}
