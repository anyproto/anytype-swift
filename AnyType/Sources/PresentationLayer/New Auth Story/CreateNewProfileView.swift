//
//  CreateNewProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct CreateNewProfileView: View {
    var body: some View {
        return ZStack {
            LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            NewProfileView()
                .padding()
        }
    }
}

struct CreateNewProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewProfileView()
    }
}

struct NewProfileView: View {
    @State var userName: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Create a new profile")
                .fontWeight(.bold)
                .font(.title)
                .padding(.bottom, 27)
            HStack {
                ImageWithCircleBackgroundView(imageName: "photo", backgroundColor: Color.gray)
                    .frame(width: 64, height: 64)
                CustomTextField(text: $userName, title: "Enter your name")
            }
            .padding(.bottom, 24)
            
            HStack(spacing: 12) {
                StandardButton(disabled: .constant(false), text: "Back", style: .white) {
                    
                }
                
                StandardButton(disabled: .constant(false), text: "Create", style: .yellow) {
                    
                }
            }
            .padding(.bottom, 16)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12.0)
    }
}
