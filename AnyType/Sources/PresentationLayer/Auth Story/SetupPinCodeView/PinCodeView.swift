//
//  PinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 31.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct PinCodeView: View {
	@EnvironmentObject var applicationState: ApplicationState
	@ObservedObject var viewModel: PinCodeViewModel
	@State var pinCode: String = ""
	@State var repeatPinCode: String = ""
	
    var body: some View {
		
		VStack(alignment: .leading, spacing: 25.0) {
			Text(viewModel.titleText).font(.title).fontWeight(.bold)
			
			if viewModel.pinCodeViewState == .setup {
				Text("Create a pin code description")
			}
			
			VStack(alignment: .leading, spacing: 5.0) {
				Text("Enter a pin code")
				SecureField("****", text: $pinCode)
					.padding()
					.textContentType(.password)
					.border(Color.gray, cornerRadius: 7.0)
			}
			
			if viewModel.pinCodeViewState == .setup {
				VStack(alignment: .leading, spacing: 5.0) {
					Text("Repeat a pin code")
					SecureField("****", text: $repeatPinCode)
						.padding()
						.textContentType(.password)
						.border(Color.gray, cornerRadius: 7.0)
				}
			}
			
			HStack {
				StandardButton(text: "Confirm", style: .yellow) {
					self.viewModel.onConfirm(password: self.pinCode)
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
		PinCodeView(viewModel: PinCodeViewModel(pinCodeViewState: .setup) {
			ApplicationState().currentRootView = .home
		}).environmentObject(ApplicationState())
    }
}
#endif
