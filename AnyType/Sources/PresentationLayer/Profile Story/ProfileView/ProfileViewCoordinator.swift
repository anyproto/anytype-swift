//
//  ProfileViewCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


final class ProfileViewCoordinator {
	
	func profileView() -> ProfileView {
		let profileService = TextileProfileService()
		let viewModel = ProfileViewModel(profileService: profileService)
		
		return ProfileView(model: viewModel)
	}
}
