//
//  LoginView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 02.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var keyboardObserver = KeyboardObserver()
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.authBackground, startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            LoginView.KeychainPhraseView(viewModel: viewModel).padding()
        }
    }
}

extension LoginView {
    struct KeychainPhraseView: View {
        @Environment(\.presentationMode) var presentationMode
        @ObservedObject var viewModel: LoginViewModel

        var body: some View {
            VStack(spacing: 0) {
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText("Login with keychain", style: .title)
                        .padding(.bottom, 27)
                    VStack(spacing: 13) {
                        HStack {
                            Image("qrIcon")
                                .padding(.trailing, 15)
                            AnytypeText("Scan QR code", style: .body)
                            Spacer()
                            Image.arrow
                        }
                        Divider()
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        self.viewModel.showQrCodeView = true
                    }

                    TextField("or Type your keychain phrase", text: $viewModel.seed)
                        .foregroundColor(.textSecondary)
                        .padding(.top, 12)
                        .padding(.bottom, 24)

                    HStack(spacing: 12) {
                        StandardButton(disabled: false, text: "Back", style: .secondary) {
                            self.presentationMode.wrappedValue.dismiss()
                        }

                        StandardButton(disabled: false, text: "Login", style: .primary) {
                            self.viewModel.recoverWallet()
                        }
                    }
                    .padding(.bottom, 16)
                }
                .padding()
                .background(Color.background)
                .cornerRadius(12.0)
                .navigationBarBackButtonHidden(true)
                .sheet(isPresented: $viewModel.showQrCodeView) {
                    QRCodeScannerView(qrCode: self.$viewModel.seed, error: self.$viewModel.error)
                }
            }
            .errorToast(isShowing: $viewModel.showError, errorText: viewModel.error ?? "")
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel())
    }
}
