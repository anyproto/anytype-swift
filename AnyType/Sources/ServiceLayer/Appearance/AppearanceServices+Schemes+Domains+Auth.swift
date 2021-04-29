//
//  AppearanceServices+Schemes+Domains+Auth.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
// NOTE: Example
/*
 struct AuthView : View {
     @ObservedObject var viewModel: AuthViewModel
     @State var selectedKey = 0
     @Environment(\.assetsCatalog) var catalog

     init(viewModel: AuthViewModel) {
         self.viewModel = viewModel

 //        UINavigationBar.appearance().barTintColor = .white
 //        UINavigationBar.appearance().shadowImage = UIImage()
     }

     var body: some View {
         NavigationView {
             VStack(alignment: .leading, spacing: 20) {

                 self.catalog.images.logo.value
                     .resizable()
                     .aspectRatio(contentMode: .fit)
                     .frame(width: 50, height: 50, alignment: .leading)
                     .padding(.bottom, 20)

                 VStack(alignment: .leading) {
                     Text(self.catalog.words.greeting.title.value)
                         .foregroundColor(Auth.BaseText(style: .title).foregroundColor)
                         .font(Auth.BaseText(style: .title).font)
                         .fontWeight(Auth.BaseText(style: .title).fontWeight)
                     Text("AnyTypeShortDescription")
                         .foregroundColor(Auth.BaseText(style: .subtitle).foregroundColor)
                         .font(Auth.BaseText(style: .subtitle).font)
                         .fontWeight(Auth.BaseText(style: .subtitle).fontWeight)
                         .layoutPriority(1)
                 }

                 VStack(alignment: .leading) {
                     if !viewModel.publicKeys.isEmpty {
                         DetailedPickerView(title: Text("Select account for public key").font(.headline),
                                            content: $viewModel.publicKeys, selected: $selectedKey)
                             .padding()
                             .background(self.catalog.colors.side.backgroundColor.value)
                             .cornerRadius(7.0)
                             .padding(.bottom, 20)

                         NavigationLink(destination: showAuthPineCodeViweOnExistsPublicKey(publicKey: viewModel.publicKeys[selectedKey])) {
                             NavigationButtonView(disabled: .constant(false), text: "Login with selected public key", style: .black)
                         }.padding(.bottom, 20)
                     }

                     VStack(alignment: .leading, spacing: 7.0) {
                         Text(viewModel.publicKeys.isEmpty ? "FirstCreateAnAccount" : "or create an account").font(.headline)

                         NavigationLink(destination: showSaverRecoveryPhraseView()) {
                             NavigationButtonView(disabled: .constant(false), text: "Create new account", style: .black)
                         }.padding(.bottom, 20)

                         Text("I have an account").font(.headline)

                         NavigationLink(destination: showEnterAccountSeedView()) {
                             NavigationButtonView(disabled: .constant(false), text: "Enter account seed", style: .black)
                         }.padding(.bottom, 20)
                     }
                 }
             }
             .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
             .padding(.horizontal, 40)
         }.modifier(Auth.BaseNavigationBar().Modifier())
     }

     private func showSaverRecoveryPhraseView() -> some View {
         let viewModel = AuthRecoveryViewModel()
         viewModel.authService = TextileAuthService()
         let view = AuthRecoveryView(viewModel: viewModel)

         return view
     }

     private func showAuthPineCodeViweOnExistsPublicKey(publicKey: String) -> some View {
         let viewModel = AuthPinCodeViewModel(authPinCodeViewType: .verify(publicKey: publicKey))
         let view = AuthPinCodeView(viewModel: viewModel)

         return view
     }

     private func showEnterAccountSeedView() -> some View {
         let viewModel = EnterAccountSeedViewModel()
         let view = EnterAccountSeedView(viewModel: viewModel)

         return view
     }
 }

 #if DEBUG
 struct SwiftUIView_Previews : PreviewProvider {
     static var previews: some View {
         let viewModel = AuthViewModel()
         viewModel.publicKeys = ["dsfsdfdsfsdfsdfsdfsdfsdf", "222222222222222", "333333333333333"]
         return AuthView(viewModel: viewModel)
     }
 }
 #endif
 */

enum Auth {
    class BaseNavigationBar: AppearanceService.Schemes.Global.Appearance.BaseNavigationBar {
        typealias BaseClass = AppearanceService.Schemes.Global.Appearance.BaseNavigationBar
        func Modifier() -> some ViewModifier {
            BaseClass.AppearanceDualModifier().setCurrent(self) // .unsetCurrent()
//            AppearanceDualModifier(self)
        }
        override init() {
            super.init()
            self.barTintColor = .pureRed
        }
    }
    class BaseText: AppearanceService.Schemes.Global.SwiftUI.BaseText {
        typealias BaseClass = AppearanceService.Schemes.Global.SwiftUI.BaseText
        // Ho-ho-ho!
        // We CAN inject environment in custom classes.
//        @Environment(\.servicesAppearance) var appearance
        enum Style {
            case title
            case subtitle
            var font: Font? {
                switch self {
                case .title: return .title
                case .subtitle: return .headline
                }
            }
            var fontWeight: Font.Weight? {
                switch self {
                case .title: return .heavy
                case .subtitle: return .regular
                }
            }
        }
        var style: Style
        init(style: Style) {
            self.style = style
            super.init()
            self.setup()
        }
        func setup() {
            self.foregroundColor = BaseClass.SingleModifier().storedScheme?.foregroundColor
            //self.appearance.schemes.scheme(for: AppearanceService.Schemes.Global.SwiftUI.BaseText.self)?.foregroundColor
            self.font = self.style.font
            self.fontWeight = self.style.fontWeight
        }
    }
}
