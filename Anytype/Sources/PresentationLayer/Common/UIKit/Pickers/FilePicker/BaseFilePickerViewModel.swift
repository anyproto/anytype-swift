//
//  BaseFilePickerViewModel.swift
//  AnyType
//
//  Created by Kovalev Alexander on 30.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Combine
import Foundation

/// Base view model for picker view controllers
class BaseFilePickerViewModel {
    
    /// Information with picked file
    @Published var resultInformation: FilePickerResultInformation?
    
    /// Handle picker file at URL
    ///
    /// - Parameters:
    ///   - information: File urls
    func process(_ information: [URL]) {
        guard let url = information.first else { return }
        self.resultInformation = .init(documentUrl: url)
    }
}
