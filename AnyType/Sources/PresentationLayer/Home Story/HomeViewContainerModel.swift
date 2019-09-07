//
//  HomeViewContainerModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


class HomeViewContainerModel {
	private var profileCoordinator = ProfileViewCoordinator()
	
	var profileView: ProfileView {
		return profileCoordinator.profileView
	}
}
