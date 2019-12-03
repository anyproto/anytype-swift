//
//  MainAuthView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct MainAuthView: View {
    
    var body: some View {
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
                        StandardButton(disabled: .constant(false), text: "Sing up", style: .white) {
                            
                        }
                        
                        StandardButton(disabled: .constant(false), text: "Login", style: .yellow) {
                            
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom, 16)
                }
                .background(Color.white)
                .cornerRadius(12.0)
                .padding(20)
            }
        }
    }
}


#if DEBUG
struct MainAuthView_Previews : PreviewProvider {
    
    static var previews: some View {
        MainAuthView()
    }
}
#endif
