//
//  PinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 31.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

enum PinCodeViewType: Equatable {
	case setup
	case verify(publicAddress: String)
	
	var title: String {
		switch self {
		case .setup:
			return "Create a pin code"
		case .verify:
			return "Create a pin code"
		}
	}
}

struct PinCodeViewModel {
	var pinCodeViewType: PinCodeViewType = .setup
	var pinCodeConfirmed: Bool = false
}

struct PinCodeView: View {
	@Binding var viewModel: PinCodeViewModel
	@State var pinCode: String = ""
	@State var repeatPinCode: String = ""
	
    var body: some View {
		VStack(alignment: .leading, spacing: 25.0) {
			Text(viewModel.pinCodeViewType.title).font(.title).fontWeight(.bold)
			
			if viewModel.pinCodeViewType == .setup {
				Text("Create a pin code description")
			}
			
			VStack(alignment: .leading, spacing: 5.0) {
				Text("Enter a pin code")
				SecureField("****", text: $pinCode)
					.padding()
					.textContentType(.password)
					.border(Color.gray, cornerRadius: 7.0)
			}
			
			if viewModel.pinCodeViewType == .setup {
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
					self.viewModel.pinCodeConfirmed = true
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
		PinCodeView(viewModel: .constant(PinCodeViewModel()))
    }
}
#endif
