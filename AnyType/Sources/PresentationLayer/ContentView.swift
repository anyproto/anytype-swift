//
//  ContentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 12.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct ContentView : View {
	@ObjectBinding var model = ContentViewModel()
	
    var body: some View {
        Text("\(model.accountName)")
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
