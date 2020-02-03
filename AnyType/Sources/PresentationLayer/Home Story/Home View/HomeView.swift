//
//  HomeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    private var viewModel = HomeViewModel()
    
    @State var showDocument: Bool = false
    @State var selectedDocumentId: String = ""
    
    var body: some View {
        NavigationView {
                VStack(alignment: .leading) {
                    NavigationLink(destination: self.viewModel.documentView(selectedDocumentId: self.selectedDocumentId).navigationBarTitle("", displayMode: .inline), isActive: self.$showDocument) {
                        return EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    
                    Text("Hi, herr Barulik")
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(.white)
                        .font(.title)
                        .padding(.top, 20)
                    GeometryReader { geometry in
                    HomeCollectionView(showDocument: self.$showDocument, selectedDocumentId: self.$selectedDocumentId,containerSize: geometry.size)
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
