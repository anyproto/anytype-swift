//
//  KeychainPhraseViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 25.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

class KeychainPhraseViewModel: ObservableObject {
    @Environment(\.keychainStoreService) private var keychainStoreService

    @Published var recoveryPhrase: String = ""
    @Published var copySeedAction: Void = () {
        didSet {
            copySeed()
        }
    }

    func viewLoaded() {
        let seed = try? keychainStoreService.obtainSeed(for: UserDefaultsConfig.usersIdKey, keyChainPassword: .userPresence)
        self.recoveryPhrase = seed ?? ""
    }

    private func copySeed() {
        UIPasteboard.general.string = recoveryPhrase
    }
}
