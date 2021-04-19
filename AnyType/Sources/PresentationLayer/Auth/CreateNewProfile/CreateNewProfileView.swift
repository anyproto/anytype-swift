//
//  CreateNewProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct CreateNewProfileView: View {
    @ObservedObject var viewModel: CreateNewProfileViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.loginBackground, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            NewProfileView(viewModel: viewModel)
                .padding()
        }
    }
}


struct CreateNewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewProfileView(viewModel: CreateNewProfileViewModel())
    }
}


private struct NewProfileView: View {
    @State private var showImagePicker: Bool = false
    @State private var createAccount: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: CreateNewProfileViewModel
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text("Create a new profile")
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(.bottom, 27)
                HStack {
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        self.showImagePicker = true
                    }) {
                        if viewModel.image != nil {
                            ImageWithCircleBackgroundView(imageName: "photo", backgroundImage: viewModel.image)
                        } else {
                            ImageWithCircleBackgroundView(imageName: "photo", backgroundColor: .gray)
                        }
                    }
                    .frame(width: 64, height: 64)
                    
                    CustomTextField(text: $viewModel.userName, title: "Enter your name")
                }
                .padding(.bottom, 24)
                
                HStack(spacing: 12) {
                    StandardButton(disabled: false, text: "Back", style: .white) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    
                    NavigationLink(destination: viewModel.showSetupWallet(), isActive: $createAccount) {
                        EmptyView()
                    }
                    StandardButton(disabled: self.viewModel.userName.count == 0, text: "Create", style: .yellow) {
                        self.createAccount = true
                    }
                }
                .padding(.bottom, 16)
            }
            .navigationBarBackButtonHidden(true)
            .padding()
            .background(Color.white)
            .cornerRadius(12.0)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: self.$viewModel.image)
        }
    }
}
