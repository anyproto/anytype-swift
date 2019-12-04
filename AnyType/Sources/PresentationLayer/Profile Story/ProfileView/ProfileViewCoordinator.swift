//
//  ProfileViewCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


final class ProfileViewCoordinator {
    private let profileService = ProfileService()
    private let textilAuthService = AnytypeAuthService()
    private lazy var viewModel = ProfileViewModel(profileService: profileService, authService: textilAuthService)
    
    var profileView: ProfileView {
        return ProfileView(model: viewModel)
    }
}
