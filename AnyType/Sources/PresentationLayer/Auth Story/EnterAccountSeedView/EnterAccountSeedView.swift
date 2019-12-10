//
//  EnterAccountSeedView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct EnterAccountSeedView: View {
    private let defautlNavColor = UINavigationBar.appearance().barTintColor
    private let defautlNavShadow = UINavigationBar.appearance().shadowImage
    
    @ObservedObject var viewModel: EnterAccountSeedViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Enter your seed phrase below")
            .font(.title).fontWeight(.bold)
            TextField("", text: $viewModel.recoveryPhrase)
            .padding()
            .background(Color("backgroundColor"))
            .cornerRadius(7)
            .font(.robotMonoRegularFontWith(size: 15.0))
            
            HStack {
                StandardButton(disabled: false, text: "Confirm", style: .yellow) {
                    self.viewModel.verifySeedPhrase()
                }
                Spacer()
            }.padding(.top, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
        .navigationBarTitle("", displayMode: .inline)
        .errorToast(isShowing: $viewModel.isShowingError, errorText: $viewModel.error)
    }
    
    private func onAppear() {
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    private func onDisappear() {
        UINavigationBar.appearance().barTintColor = defautlNavColor
        UINavigationBar.appearance().shadowImage = defautlNavShadow
    }
    
}

#if DEBUG
struct EnterAccountSeedView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = EnterAccountSeedViewModel()
        return NavigationView {
            EnterAccountSeedView(viewModel: viewModel)
        }
    }
}
#endif
