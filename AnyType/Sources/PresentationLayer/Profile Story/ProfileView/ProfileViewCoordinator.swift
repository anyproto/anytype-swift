//
//  ProfileViewCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


class ProfileViewCoordinator {
	
	func profileView() -> ProfileView {
		let viewModel = ProfileViewModel()
		
		return ProfileView(model: viewModel)
	}
}
