//
//  ProfileViewCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

final class ProfileViewCoordinator {
    private let profileService: ProfileService = .init()
    private let authService: AuthService = .init()
    lazy private(set) var viewModel: ProfileViewModel = .init(profileService: self.profileService, authService: self.authService)
    
    var profileView: some View {
        ProfileView(model: self.viewModel)
    }
}
