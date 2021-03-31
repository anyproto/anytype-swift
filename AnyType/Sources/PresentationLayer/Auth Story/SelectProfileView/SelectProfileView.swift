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
            NavigationView {
                ZStack(alignment: self.viewModel.isMultipleAccountsEnabled ? .bottom : .center) {
                    LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    if self.viewModel.isMultipleAccountsEnabled {
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
                    } else {
                        ProgressView()
                    }
                }
            }
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
            UserIconView(image: self.viewModel.image, color: self.viewModel.color, name: self.viewModel.name)
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
            Spacer(minLength: 10).frame(minWidth: 10, maxWidth: nil)
        }
    }
}

//struct SomeProfileStruct: View {
//    var name: String { "A" }
//    var color: UIColor? { nil }
//    var image: UIImage? { nil }
//    var peers: String? { nil }
//
//    var body: some View {
//        HStack {
//            UserIconView(image: self.image, color: self.color, name: self.name)
//            VStack(alignment: .leading, spacing: 0) {
//                Text(self.name)
//                    .foregroundColor(.black)
//                    .padding(.bottom, 3)
//                HStack {
//                    Image("uploaded")
//                        .clipShape(Circle())
//                    Text(self.peers ?? "no peers")
//                        .foregroundColor(self.peers != nil ? Color.black : Color("GrayText"))
//                }.background(Color.green)
//            }
//            Spacer(minLength: 10).frame(minWidth: 10, maxWidth: nil)
//        }
//    }
//}

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
