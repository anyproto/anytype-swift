//
//  HomeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    @State var showDocument: Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    NavigationLink(destination: DocumentView(), isActive: self.$showDocument) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    
                    Text("Hi, herr Barulik")
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(.top, 20)
                    HomeCollectionView(showDocument: self.$showDocument, containerSize: geometry.size)
                        .padding()
                }
            }
            .background(LinearGradient(gradient: /*@START_MENU_TOKEN@*/Gradient(colors: [Color.red, Color.blue])/*@END_MENU_TOKEN@*/, startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/).edgesIgnoringSafeArea(.all))
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct DocumentItem: View {
    var name: String
    
    var body: some View {
        Text(name)
    }
}
