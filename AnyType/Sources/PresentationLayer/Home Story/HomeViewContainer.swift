//
//  HomeViewContainer.swift
//  AnyType
//
//  Created by Denis Batvinkin on 22.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

enum TabIdentifer {
    case home
    case profile
}

struct HomeViewContainer: View {
    @State var selectedTab: TabIdentifer = .home
    var model: HomeViewContainerModel
    
    var oldBody: some View {
        TabView(selection: $selectedTab) {
            model.homeView
                .tabItem {
                    Text("Home").font(.headline)
            }
            .tag(TabIdentifer.home)

            model.profileView
                .tabItem {
                    Text("Profile")
            }
            .tag(TabIdentifer.profile)
        }
    }
    var body: some View {
        oldBody
//        newBody
    }
    var newBody: some View {
//        model.profileView
        DocumentViewBuilder.documentView(by: .init(id: "1"))
    }
}

#if DEBUG
struct HomeViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        HomeViewContainer(model: HomeViewContainerModel())
    }
}
#endif
