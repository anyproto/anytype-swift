//
//  MainAuthView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct MainAuthView: View {
    @ObservedObject var viewModel: MainAuthViewModel
    @State private var navigateToLogin: Int? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("mainAuthBackground")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading) {
                    Image("logo")
                        .padding(.leading, 20)
                        .padding(.top, 30)
                    Spacer()
                    VStack {
                        Text("Organazie everything")
                            .padding(20)
                            .font(.title)
                        Text("OrganazieEverythingDescription")
                            .padding([.leading, .trailing, .bottom], 20)
                        
                        HStack {
                            NavigationLink(destination: viewModel.showCreateProfileView(), isActive: $viewModel.shouldShowCreateProfileView) {
                                EmptyView()
                            }
                            StandardButton(disabled: .constant(false), text: "Sing up", style: .white) {
                                self.viewModel.singUp()
                            }
                            
                            NavigationLink(destination: viewModel.showLoginView(), tag: 1, selection: $navigateToLogin) {
                                StandardButton(disabled: .constant(false), text: "Login", style: .yellow) {
                                    self.navigateToLogin = 1
                                }
                            }
                        }
                        .padding([.leading, .trailing], 20)
                        .padding(.bottom, 16)
                    }
                    .background(Color.white)
                    .cornerRadius(12.0)
                    .padding(20)
                }
                .errorToast(isShowing: $viewModel.isShowingError, errorText: $viewModel.error)
                .navigationBarTitle("")
                .navigationBarHidden(true)
            }
        }
    }
}


#if DEBUG
struct MainAuthView_Previews : PreviewProvider {
    
    static var previews: some View {
        MainAuthView(viewModel: MainAuthViewModel())
    }
}
#endif
