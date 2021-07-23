//
//  PinCodeViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 14.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine

enum PinCodeViewType: Equatable {
    case setup
    case verify
    
    var title: String {
        switch self {
        case .setup:
            return "Create pin code"
        case .verify:
            return "Verify pin code"
        }
    }
    
    func validator(viewModel: PinCodeViewModel) -> AnyPublisher<String?, Never> {
        switch self {
        case .setup:
            return CreatePinCodeValidator(viewModel: viewModel).validatePinCode
        case .verify:
            return VerifyPinCodeValidator(viewModel: viewModel).validatePinCode
        }
    }
}

class PinCodeViewModel: ObservableObject {
    var pinCodeViewType: PinCodeViewType
    var maxLenght: Int = 4
    
    @Published var pinCode: String = ""
    @Published var repeatPinCode: String = ""
    
    lazy var validatedPassword = pinCodeViewType.validator(viewModel: self)
    
    var pinCodeStream: AnyCancellable?
    
    init(pinCodeViewType: PinCodeViewType) {
        self.pinCodeViewType = pinCodeViewType
    }
}
