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
	private var profileService: ProfileServiceProtocol
	private var authService: AuthServiceProtocol
	
	@Published var error: String = "" {
		didSet {
			isShowingError = true
		}
	}
	@Published var isShowingError: Bool = false
	
	@Published var accountName: String = "" {
		didSet {
			profileService.name = accountName
		}
	}
	@Published var accountAvatar: UIImage? {
		didSet {
			// TODO: load avatar to ipfs by textile api
		}
	}
	@Published var selectedColor: UIColor = .blue
	
	@Published var updates: Bool = UserDefaultsConfig.notificationUpdates {
		didSet {
			UserDefaultsConfig.notificationUpdates = updates
		}
	}
	@Published var newInvites: Bool = UserDefaultsConfig.notificationNewInvites {
		didSet {
			UserDefaultsConfig.notificationNewInvites = newInvites
		}
	}
	@Published var newComments: Bool = UserDefaultsConfig.notificationNewComments {
		didSet {
			UserDefaultsConfig.notificationNewComments = newComments
		}
	}
	@Published var newDevice: Bool = UserDefaultsConfig.notificationNewDevice {
		didSet {
			UserDefaultsConfig.notificationNewDevice = newDevice
		}
	}
	
	// MARK: - Lifecycle
	
	init(profileService: ProfileServiceProtocol, authService: AuthServiceProtocol) {
		self.profileService = profileService
		self.authService = authService
	}
	
	// MARK: - Public methods
	
	func obtainAccountInfo() {
		accountName = profileService.name
		
		if let avatarURL = URL(string: profileService.avatar) {
			self.accountAvatar = ImageLoaderCache.shared.loaderFor(path: avatarURL).image
		}
	}
	
	func logout() {
		authService.logout() { [weak self] in
			let authViewCoordinator = AuthViewCoordinator()
			let view = authViewCoordinator.authView()
			applicationCoordinator?.startNewRootView(content: view)
		}
	}
}
