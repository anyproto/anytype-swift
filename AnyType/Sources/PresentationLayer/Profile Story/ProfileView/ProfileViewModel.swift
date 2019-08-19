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

struct NotificationSettings {
	let updates: Bool = false
}

final class ProfileViewModel: ObservableObject {
	@Published var accountName: String = ""
	@Published var accountImage: UIImage? = nil
	
	@Published var updates: Bool = false
	@Published var newInvites: Bool = false
	@Published var newComments: Bool = false
	@Published var newDevice: Bool = false
	
	func obtainAccountName() {
		var error: NSError?
		let profile = Textile.instance().profile.get(&error)
		if (error != nil) {
			// Do something with this error
		} else {
			accountName = profile.name
		}
	}
}
