//
//  HomeView.swift
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

struct HomeView: View {
	@State var selectedTab: TabIdentifer = .home
	
    var body: some View {
		TabView(selection: $selectedTab) {
			Text(/*@START_MENU_TOKEN@*/"Hello World!"/*@END_MENU_TOKEN@*/)
				.tabItem {
					Text("Home")
			}
			.tag(TabIdentifer.home)
			
//			profileView()
//				.tabItem {
//					Text("Profile")
//			}
//			.tag(TabIdentifer.profile)
		}
    }
	
	private func profileView() -> some View {
		let coordinator = ProfileViewCoordinator()
		return coordinator.profileView()
	}
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
#endif
