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
	@EnvironmentObject var applicationState: ApplicationState
	
    var body: some View {
		
		VStack(alignment: .leading, spacing: 25.0) {
			Text("Create a pin code").font(.title).fontWeight(.bold)
			Text("Create a pin code description")
			
			VStack(alignment: .leading, spacing: 5.0) {
				Text("Enter a pin code")
				SecureField("****", text: $pinCode)
					.padding()
					.textContentType(.password)
					.border(Color.gray, cornerRadius: 7.0)
			}
			
			VStack(alignment: .leading, spacing: 5.0) {
				Text("Repeat a pin code")
				SecureField("****", text: $pinCode)
					.padding()
					.textContentType(.password)
					.border(Color.gray, cornerRadius: 7.0)
			}
			
			HStack {
				StandardButton(text: "Confirm", style: .yellow) {
					self.applicationState.currentRootView = .home
				}
				Spacer()
			}
		}
		.frame(maxHeight: .infinity ,alignment:  .topLeading)
		.padding(.top, 40).padding(.horizontal, 20)
    }
	
}

#if DEBUG
struct SetupPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        SetupPinCodeView()
    }
}
#endif
