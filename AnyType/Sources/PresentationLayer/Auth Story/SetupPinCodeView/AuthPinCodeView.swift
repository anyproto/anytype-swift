//
//  AuthPinCodeView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 05.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct AuthPinCodeView: View {
    private let defautlNavColor = UINavigationBar.appearance().barTintColor
    private let defautlNavShadow = UINavigationBar.appearance().shadowImage
    
    @ObservedObject var viewModel: AuthPinCodeViewModel
    
    var body: some View {
        VStack {
            OldPinCodeView(viewModel: $viewModel.pinCodeViewModel, pinCodeConfirmed: {
                self.viewModel.onConfirm()
            })
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .navigationBarTitle("", displayMode: .inline)
        .onDisappear(perform: restoreNavigationApperance)
        .errorToast(isShowing: $viewModel.isShowingError,  errorText: viewModel.error)
    }
    
    private func restoreNavigationApperance() {
        UINavigationBar.appearance().barTintColor = defautlNavColor
        UINavigationBar.appearance().shadowImage = defautlNavShadow
    }
}

#if DEBUG
struct AuthPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthPinCodeViewModel(authPinCodeViewType: .setup)
        viewModel.recoveryPhrase = "bla bla bla"
        
        return AuthPinCodeView(viewModel: viewModel)
    }
}
#endif
