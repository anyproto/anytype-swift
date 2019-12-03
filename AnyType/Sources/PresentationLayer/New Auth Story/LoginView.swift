//
//  LoginView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        return ZStack {
            LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            KeychainPhraseView()
                .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct KeychainPhraseView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Login with keychain")
                .fontWeight(.bold)
                .font(.title)
                .padding(.bottom, 27)
            VStack(spacing: 13) {
                HStack {
                    Image("qrIcon")
                        .padding(.trailing, 15)
                    Text("Scan QR code")
                    Spacer()
                    Image("arrowForward")
                }
                Divider()
            }
            
            Text("or Type your keychain phrase")
                .foregroundColor(Color("GrayText"))
                .padding(.top, 12)
                .padding(.bottom, 97)
            HStack(spacing: 12) {
                StandardButton(disabled: .constant(false), text: "Back", style: .white) {
                    
                }
                
                StandardButton(disabled: .constant(false), text: "Login", style: .yellow) {
                    
                }
            }
            .padding(.bottom, 16)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12.0)
    }
}
