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
	var model = HomeViewContainerModel()
	
	var body: some View {
		TabView(selection: $selectedTab) {
			Text(/*@START_MENU_TOKEN@*/"Hello World!"/*@END_MENU_TOKEN@*/)
				.tabItem {
					Text("Home")
			}
			.tag(TabIdentifer.home)
			
			model.profileView
				.tabItem {
					Text("Profile")
			}
			.tag(TabIdentifer.profile)
		}
	}
}

#if DEBUG
struct HomeViewContainer_Previews: PreviewProvider {
	static var previews: some View {
		HomeViewContainer()
	}
}
#endif
