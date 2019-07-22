//
//  ProfileView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 12.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct ProfileView : View {
	@ObjectBinding var model = ProfileViewModel()
	
    var body: some View {
        Text("\(model.accountName)")
    }
}

#if DEBUG
struct ProfileView_Previews : PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif
