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
        HStack {
            ZStack(alignment: self.viewModel.isMultipleAccountsEnabled ? .bottom : .center) {
                LinearGradient(gradient: Gradients.loginBackground, startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                if self.viewModel.isMultipleAccountsEnabled {
                    VStack {
                        ScrollView {
                            VStack(alignment: .leading) {
                                AnytypeText("Choose profile", style: .title)
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
                } else {
                    ProgressView()
                }
            }
            .embedInNavigation()
            .onAppear {
                self.viewModel.accountRecover()
            }
            .errorToast(isShowing: self.$viewModel.showError, errorText: self.viewModel.error ?? "")
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
            AnytypeText("Add profile", style: .bodySemibold)
                .foregroundColor(.textSecondary)
        }
    }
}


private struct ProfileNameView: View {
    @ObservedObject var viewModel: ProfileNameViewModel
    
    var body: some View {
        HStack {
            UserIconView(image: self.viewModel.image, name: self.viewModel.name)
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(viewModel.name, style: .body)
                    .foregroundColor(.textPrimary)
                    .padding(.bottom, 3)
                HStack {
                    Image("uploaded")
                        .clipShape(Circle())
                    AnytypeText(viewModel.peers ?? "no peers", style: .body)
                        .foregroundColor(viewModel.peers != nil ? .textPrimary : .textSecondary)
                }
            }
            Spacer(minLength: 10).frame(minWidth: 10, maxWidth: nil)
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
        profile2.image = UIImage(named: "logo-sign-part-mobile")
        let profile3 = ProfileNameViewModel(id: "3")
        profile3.name = "Tony Leung"
        viewModel.profilesViewModels = [profile1, profile2]
        
        return SelectProfileView(viewModel: viewModel)
    }
}
