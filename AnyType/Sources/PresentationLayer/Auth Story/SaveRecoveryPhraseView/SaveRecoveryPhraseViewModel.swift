//
//  SaveRecoveryPhraseViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 30.07.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine
import SwiftUI

class SaveRecoveryPhraseViewModel: ObservableObject {
	let willChange = PassthroughSubject<SaveRecoveryPhraseViewModel, Never>()
	
	var recoveryPhrase: String {
		willSet {
			willChange.send(self)
		}
	}
	
	init(recoveryPhrase: String) {
		self.recoveryPhrase = recoveryPhrase
	}
}
