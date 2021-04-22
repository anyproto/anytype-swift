//
//  ProfileSettingsView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

enum Colors {
    static let colors: [UIColor] = [.black, .gray, .yellow, .red, .purple, .blue, .green]
}

struct ProfileSettingsView: View {
    private let defautlNavColor = UINavigationBar.appearance().barTintColor
    private let defautlNavShadow = UINavigationBar.appearance().shadowImage
    
    @Binding var accountImage: UIImage?
    @Binding var accountName: String
    @Binding var selectedColor: UIColor
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                if self.accountImage != nil {
                    Image(uiImage: accountImage!)
                } else {
                    Text(String(accountName.first ?? "A"))
                        .fontWeight(.bold)
                        .font(.largeTitle)
                        .padding(.all, 50)
                        .background(Color(selectedColor))
                        .foregroundColor(Color.white)
                        .clipShape(Circle())
                }
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .offset(x: -10, y: -10)
                    .foregroundColor(Color("GrayText"))
            }
            Text("Background color")
                .fontWeight(.bold)
                .font(.headline)
                .padding(.top)
            
            SelectColorView(colors: Colors.colors, selectedColor: $selectedColor)
            
            Divider()
                .padding(.trailing, -20)
                .padding(.top, 20)
            
            Text("Name")
                .fontWeight(.bold)
                .font(.headline)
                .padding(.top)
            
            TextField("", text: $accountName)
                .font(.title)
                .lineLimit(1)
                .padding(.top)
            
            Divider()
                .padding(.trailing, -20)
                .padding(.top, 20)
            
        }
        .navigationBarTitle("", displayMode: .inline)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func onAppear() {
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    private func onDisappear() {
        UINavigationBar.appearance().barTintColor = defautlNavColor
        UINavigationBar.appearance().shadowImage = defautlNavShadow
    }
}

#if DEBUG
struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            ProfileSettingsView(accountImage: .constant(nil), accountName: .constant("Anton Pronkin"), selectedColor: .constant(.blue))
        }
    }
}
#endif
