//
//  AuthViewCoordinator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import UIKit

class AuthViewCoordinator {
    
    // MARK: - Public methods
    
    func authView() -> AuthView {
        let viewModel = AuthViewModel()
        let view = AuthView(viewModel: viewModel)
        
        return view
    }
    
}
