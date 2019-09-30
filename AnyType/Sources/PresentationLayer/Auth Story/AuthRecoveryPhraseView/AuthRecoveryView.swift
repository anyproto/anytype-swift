//
//  AuthRecoveryView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import UIKit

struct AuthRecoveryView: View {
    private let defautlNavColor = UINavigationBar.appearance().barTintColor
    private let defautlNavShadow = UINavigationBar.appearance().shadowImage
    
    @ObservedObject var viewModel: AuthRecoveryViewModel
    
    var body: some View {
        VStack {
            SaveRecoveryPhraseView(model: $viewModel.saveRecoveryModel)
                .layoutPriority(1)
            NavigationLink(destination: showPinCodeView(state: .setup), isActive: $viewModel.saveRecoveryModel.recoveryPhraseSaved) {
                EmptyView()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .navigationBarTitle("", displayMode: .inline)
        .onAppear(perform: createRecoveryPhrase)
        .onDisappear(perform: restorNavigationApperance)
        
    }
    
    private func createRecoveryPhrase() {
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().shadowImage = UIImage()
        viewModel.createAccount()
    }
    
    private func restorNavigationApperance() {
        UINavigationBar.appearance().barTintColor = defautlNavColor
        UINavigationBar.appearance().shadowImage = defautlNavShadow
    }
    
    private func showPinCodeView(state: PinCodeViewType) -> some View {
        let viewModel = AuthPinCodeViewModel(authPinCodeViewType: .setup)
        viewModel.recoveryPhrase = self.viewModel.saveRecoveryModel.recoveryPhrase
        let view = AuthPinCodeView(viewModel: viewModel)
        
        return view
    }
}

#if DEBUG
struct AuthRecoveryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AuthRecoveryViewModel()
        viewModel.saveRecoveryModel.recoveryPhrase = "some phrase to save some phrase to save"
        
        return AuthRecoveryView(viewModel: viewModel)
    }
}
#endif
