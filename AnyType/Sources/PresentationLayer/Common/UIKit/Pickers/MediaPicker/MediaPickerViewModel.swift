//
//  MediaPickerViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

// MARK: - ViewModel

extension MediaPicker {
    
    final class ViewModel {
        
        var onResultInformationObtain: ((FilePickerResultInformation?) -> Void)?
        
        let type: MediaPickerContentType
        
        init(type: MediaPickerContentType) {
            self.type = type
        }
        
        func process(_ url: URL?) {
            onResultInformationObtain?(
                url.flatMap { FilePickerResultInformation(documentUrl: $0) }
            )
        }
    }
    
}
