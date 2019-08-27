//
//  PinCodeValidator.swift
//  AnyType
//
//  Created by Denis Batvinkin on 14.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine

protocol PinCodeValidator {
	var validatePinCode: AnyPublisher<String?, Never> { get }
}

struct CreatePinCodeValidator: PinCodeValidator {
	var viewModel: PinCodeViewModel
	
	var validatePinCode: AnyPublisher<String?, Never> {
		return Publishers.CombineLatest(viewModel.$pinCode, viewModel.$repeatPinCode)
			.map { pinCode, repeatPinCode in
				guard pinCode == repeatPinCode, pinCode.count > 3 else { return nil }
				return pinCode
		}.eraseToAnyPublisher()
	}
}

struct VerifyPinCodeValidator: PinCodeValidator {
	var viewModel: PinCodeViewModel
	
	var validatePinCode: AnyPublisher<String?, Never> {
		return Just(viewModel.pinCode).eraseToAnyPublisher()
	}
}
