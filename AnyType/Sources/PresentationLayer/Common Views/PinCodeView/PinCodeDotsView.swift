//
//  PinCodeDotsView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 31.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct PinCodeDotsView: View {
	@State var pinCode: String = ""
	
    var body: some View {
        VStack {
            HStack {
                Circle()
                Circle()
                Circle()
                Circle()
            }
			.padding()
			.shadow(color: Color("yellow"), radius: 10)
			.foregroundColor(Color("yellow"))
        }
    }
}

#if DEBUG
struct PinCodeDotsView_Previews: PreviewProvider {
    static var previews: some View {
        PinCodeDotsView()
    }
}
#endif
