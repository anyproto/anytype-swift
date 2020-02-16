//
//  HomeViewContainerModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//


class HomeViewContainerModel {
    private let dashboardSerive = DashboardService()
    private var profileCoordinator = ProfileViewCoordinator()
    
    
    init() {
        _ = dashboardSerive.openDashboard()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    print("dashboard success")
                case .failure(let error):
                    print("dashboard failure")
                }
            }) { _ in
                
        }
    }
    
    var profileView: ProfileView {
        return profileCoordinator.profileView
    }
    
    var homeView: HomeView {
        return HomeView()
    }
}
