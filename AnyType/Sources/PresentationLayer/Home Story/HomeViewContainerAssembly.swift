//
//  HomeViewContainerAssembly.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

class HomeViewContainerAssembly {
    
    // MARK: - Public methods
    
    func createHomeViewContainer() -> HomeViewContainer {
        let viewModel = HomeViewContainerModel()
        let homeViewContainer = HomeViewContainer()
        
        return homeViewContainer
    }
}
