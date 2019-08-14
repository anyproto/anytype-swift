//
//  PinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 31.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine

enum PinCodeViewType: Equatable {
	case setup
	case verify(publicAddress: String)
	
	var title: String {
		switch self {
		case .setup:
			return "Create a pin code"
		case .verify:
			return "Verify pin code"
		}
	}
}

class PinCodeViewModel: ObservableObject {
	var pinCodeViewType: PinCodeViewType = .setup
	
	@Published var pinCode: String = ""
	@Published var repeatPinCode: String = ""
	
	var validatedPassword: AnyPublisher<String?, Never> {
		return Publishers.CombineLatest($pinCode, $repeatPinCode)
			.map { pinCode, repeatPinCode in
				guard pinCode == repeatPinCode, pinCode.count > 3 else { return nil }
				return pinCode
		}.eraseToAnyPublisher()
	}
	
	var pinCodeStream: AnyCancellable?
}

typealias OnPinCodeConfirmed = () -> Void
	
struct PinCodeView: View {
	@Binding var viewModel: PinCodeViewModel
	@State var confirmIsDisabled = true
	var pinCodeConfirmed: OnPinCodeConfirmed
	
    var body: some View {
		VStack(alignment: .leading, spacing: 25.0) {
		Text(viewModel.pinCodeViewType.title).font(.title).fontWeight(.bold)
			
			if viewModel.pinCodeViewType == .setup {
				Text("Create a pin code description")
			}
			
			VStack(alignment: .leading, spacing: 5.0) {
				Text("Enter a pin code")
				SecureField("••••", text: $viewModel.pinCode)
					.padding()
					.textContentType(.password)
					.overlay(RoundedRectangle(cornerRadius: 7.0).stroke().foregroundColor(Color.gray))
			}
			
			if viewModel.pinCodeViewType == .setup {
				VStack(alignment: .leading, spacing: 5.0) {
					Text("Repeat a pin code")
					SecureField("••••", text: $viewModel.repeatPinCode)
						.padding()
						.textContentType(.password)
						.overlay(RoundedRectangle(cornerRadius: 7.0).stroke().foregroundColor(Color.gray))
				}
			}
			
			HStack {
				StandardButton(disabled: confirmIsDisabled, text: "Confirm", style: .yellow) {
					self.pinCodeConfirmed()
				}
				Spacer()
			}
		}.onAppear(perform: onAppear)
	}
	
	private func onAppear() {
		viewModel.pinCodeStream = viewModel.validatedPassword
			.map{ $0 == nil }
			.receive(on: RunLoop.main)
			.assign(to: \.confirmIsDisabled, on: self)
	}
}

#if DEBUG
struct SetupPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
		PinCodeView(viewModel: .constant(PinCodeViewModel()), pinCodeConfirmed: {})
    }
}
#endif
