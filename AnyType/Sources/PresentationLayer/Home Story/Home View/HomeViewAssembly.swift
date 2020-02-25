//
//  HomeViewAssembly.swift
//  AnyType
//
//  Created by Denis Batvinkin on 24.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

class HomeViewAssembly {
    
    func createHomeView() -> HomeView {
        let viewModel = HomeViewModel(homeCollectionViewAssembly: HomeCollectionViewAssembly())
        let homeView = HomeView(viewModel: viewModel, collectionViewModel: HomeCollectionViewModel())
        
        return homeView
    }
}
