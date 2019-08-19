//
//  ProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 12.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct ProfileView : View {
	private let defautlNavColor = UINavigationBar.appearance().barTintColor
	private let defautlNavShadow = UINavigationBar.appearance().shadowImage
	   
	@ObservedObject var model: ProfileViewModel
	
	var body: some View {
		NavigationView {
			VStack(alignment: .leading) {
				VStack {
					if model.accountImage != nil {
						Image(uiImage: model.accountImage!)
					} else {
						Text(String(model.accountName.first ?? "A"))
							.padding()
							.background(Color.blue)
							.foregroundColor(Color.white)
							.clipShape(Circle())
							.overlay(Circle().stroke(Color.white))
					}
					Text("\(model.accountName)")
				}
				.padding()
				
				Form {
					NavigationLink(destination: Text("123")) {
						Text("Profile settings")
							.fontWeight(.bold)
							.foregroundColor(Color.black)
							.padding([.top, .bottom])
					}
					
					VStack(alignment: .leading) {
						Text("Notifications")
						Toggle(isOn: $model.updates) {
							Text("Updates")
						}
						Toggle(isOn: $model.updates) {
							Text("New invites")
						}
						Toggle(isOn: $model.updates) {
							Text("New comments")
						}
						Toggle(isOn: $model.updates) {
							Text("New device paired")
						}
					}.padding(.top)
					
					NavigationLink(destination: Text("123")) {
						Text("Pin code")
							.fontWeight(.bold)
							.foregroundColor(Color.black)
							.padding([.top, .bottom])
					}
					
					NavigationLink(destination: Text("123")) {
						Text("Keychain phrase")
							.fontWeight(.bold)
							.foregroundColor(Color.black)
							.padding([.top, .bottom])
					}
					
					NavigationLink(destination: Text("123")) {
						Text("About")
							.fontWeight(.bold)
							.foregroundColor(Color.black)
							.padding([.top, .bottom])
					}
				}
			}
			.background(Color("backgroundColor"))
			.navigationBarTitle("", displayMode: .inline)
		}
		.onAppear(perform: onAppear)
		.onDisappear(perform: onDisappear)
	}
	
	private func onAppear() {
		UINavigationBar.appearance().barTintColor = UIColor(named: "backgroundColor")
		UINavigationBar.appearance().shadowImage = UIImage()
	}
	
	private func onDisappear() {
		UINavigationBar.appearance().barTintColor = defautlNavColor
		UINavigationBar.appearance().shadowImage = defautlNavShadow
	}
}

#if DEBUG
struct ProfileView_Previews : PreviewProvider {
	static var previews: some View {
		let viewModel = ProfileViewModel()
		return ProfileView(model: viewModel)
	}
}
#endif
