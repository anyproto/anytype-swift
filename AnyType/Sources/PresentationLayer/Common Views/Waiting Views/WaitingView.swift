//
//  WaitingView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct WaitingView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 16) {
                    Image("clock")
                        .background(Circle()
                            .fill(Color("backgroundColor"))
                            .frame(width: 64, height: 64)
                    ).frame(width: 64, height: 64)
                    
                    Text("Setting up the wallet…")
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12.0)
            }
            .padding(20)
        }
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView()
    }
}
