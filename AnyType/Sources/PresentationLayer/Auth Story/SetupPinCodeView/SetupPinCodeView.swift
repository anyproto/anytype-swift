//
//  SetupPinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 31.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct SetupPinCodeView: View {
	@State var pinCode: String = ""
	
    var body: some View {
		TextField("Pin code", text: $pinCode)
    }
}

#if DEBUG
struct SetupPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        SetupPinCodeView()
    }
}
#endif
