//
//  TextileProfileService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Textile


final class TextileProfileService: ProfileServiceProtocol {
	private let profile = Textile.instance().profile
	
	var name: String = "" {
		didSet {
			var error: NSError?
			profile.setName(name, error: &error)
			
			if error != nil {
				name = oldValue
			}
		}
	}
	var avatar: String = "" {
		didSet {
			profile.setAvatar(avatar) { block, error in
			}
		}
	}
	
	init() {
		name = profile.name(nil)
		avatar = profile.avatar(nil)
	}
}
