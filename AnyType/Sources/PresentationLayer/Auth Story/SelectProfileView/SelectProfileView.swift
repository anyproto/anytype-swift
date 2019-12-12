//
//  SelectProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct SelectProfileView: View {
    @ObservedObject var viewModel: SelectProfileViewModel
    @State var showCreateProfileView = false
    @State var contentHeight: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text("Choose profile")
                                .font(.title)
                                .fontWeight(.bold)
                            .animation(nil)
                            
                            ForEach(self.viewModel.profilesViewModels) { profile in
                                Button(action: {
                                    self.viewModel.selectProfile(id: profile.id)
                                }) {
                                    ProfileNameView(viewModel: profile)
                                }
                                .transition(.opacity)
                            }
                            .animation(nil)
                            NavigationLink(destination: self.viewModel.showCreateProfileView()) {
                                AddProfileView()
                            }
                            .animation(nil)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(
                            GeometryReader { proxy in
                                self.contentHeight(proxy: proxy)
                        })
                            .animation(.easeInOut(duration: 0.6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: contentHeight)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .animation(.easeInOut(duration: 0.5))
                }
                .padding()
            }
        }
        .onAppear {
            self.viewModel.accountRecover()
        }
    }
    
    private func contentHeight(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.contentHeight = proxy.size.height
        }
        return Color.clear
    }
}


struct AddProfileView: View {
    
    var body: some View {
        HStack {
            Image("plus")
                .frame(width: 48, height: 48)
            Text("Add profile")
                .fontWeight(.semibold)
                .foregroundColor(Color("GrayText"))
        }
    }
}


private struct ProfileNameView: View {
    @ObservedObject var viewModel: ProfileNameViewModel
    
    var body: some View {
        HStack {
            if viewModel.image != nil {
                UserIconView(image: viewModel.image, name: viewModel.name)
                    .frame(width: 48, height: 48)
            } else {
                UserIconView(color: viewModel.color, name: viewModel.name)
                    .frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.name)
                    .foregroundColor(.black)
                    .padding(.bottom, 3)
                HStack {
                    Image("uploaded")
                        .clipShape(Circle())
                    Text(viewModel.peers ?? "no peers")
                        .foregroundColor(viewModel.peers != nil ? Color.black : Color("GrayText"))
                }
            }
        }
    }
}

struct SelectProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel =  SelectProfileViewModel()
        let profile1 = ProfileNameViewModel(id: "1")
        profile1.name = "Anton Pronkin"
        let profile2 = ProfileNameViewModel(id: "2")
        profile2.name = "James Simon"
        let profile3 = ProfileNameViewModel(id: "3")
        profile3.name = "Tony Leung"
        viewModel.profilesViewModels = [profile1]
        
        return SelectProfileView(viewModel: viewModel)
    }
}
