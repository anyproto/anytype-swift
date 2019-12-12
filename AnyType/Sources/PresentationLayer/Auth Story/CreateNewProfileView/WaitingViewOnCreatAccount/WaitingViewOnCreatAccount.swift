//
//  WaitingViewOnCreatAccount.swift
//  AnyType
//
//  Created by Denis Batvinkin on 10.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct WaitingViewOnCreatAccount: View {
    @ObservedObject var viewModel: WaitingViewOnCreatAccountModel
    
    var body: some View {
        VStack {
            WaitingView(text: "Setting up the wallet…", errorState: viewModel.error != nil, errorText: viewModel.error)
        }
        .onAppear {
            self.viewModel.createAccount()
        }
    }
}

struct WaitingViewOnCreatAccount_Previews: PreviewProvider {
    static var previews: some View {
        WaitingViewOnCreatAccount(viewModel: WaitingViewOnCreatAccountModel(userName: "Stoya", image: nil))
    }
}
