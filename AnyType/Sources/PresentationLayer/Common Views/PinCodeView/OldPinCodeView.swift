//
//  OldPinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 31.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

typealias OnPinCodeConfirmed = () -> Void
    
struct OldPinCodeView: View {
    @Binding var viewModel: PinCodeViewModel
    @State var confirmIsDisabled = false
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
        }
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        #if !targetEnvironment(simulator)
        viewModel.pinCodeStream = viewModel.validatedPassword
            .map{ $0 == nil }
            .receive(on: RunLoop.main)
            .assign(to: \.confirmIsDisabled, on: self)
        #endif
    }
}

#if DEBUG
struct SetupPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PinCodeViewModel(pinCodeViewType: .setup)
        return OldPinCodeView(viewModel: .constant(viewModel), pinCodeConfirmed: {})
    }
}
#endif
