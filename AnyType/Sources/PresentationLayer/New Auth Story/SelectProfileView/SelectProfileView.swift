//
//  SelectProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 03.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct SelectProfileView: View {
    @State var profiles: [ProfileModel.Profile] = [ProfileModel.Profile(name: "Anton Pronkin", peers: "32/129", uploaded: false), ProfileModel.Profile(name: "James Simon", peers: "0/36", uploaded: true), ProfileModel.Profile(name: "Tony Leung", uploaded: false)]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(gradient: Gradients.LoginBackground.gradient, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Choose profile")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        ForEach(profiles) { profile in
                            Button(action: {
                                
                            }) {
                                ProfileNameView(image: profile.image, name: profile.name, peers: profile.peers)
                            }
                        }
                        Button(action: {
                            
                        }) {
                            AddProfileView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
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

struct ProfileNameView: View {
    var image: UIImage?
    var name: String
    var peers: String?
    
    var body: some View {
        HStack {
            UserIconView(image: nil, name: "Anton B")
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                Text(name)
                    .foregroundColor(.black)
                    .padding(.bottom, 3)
                HStack {
                    Image("uploaded")
                        .clipShape(Circle())
                    Text(peers ?? "no peers")
                        .foregroundColor(peers != nil ? Color.black : Color("GrayText"))
                }
            }
        }
    }
}

struct SelectProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SelectProfileView()
    }
}
