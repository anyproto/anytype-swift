//
//  ObjectSettingsViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Combine
import BlocksModels

final class ObjectSettingsViewModel: ObservableObject {
    
    @Published private(set) var settings: [ObjectSetting] = ObjectSetting.allCases
    
    private let objectDetailsService: ObjectDetailsService
    
    init(objectDetailsService: ObjectDetailsService) {
        self.objectDetailsService = objectDetailsService
    }
    
    func update(with details: DetailsData) {
        guard let layout = details.layout else {
            settings = ObjectSetting.allCases
            return
        }
        switch layout {
        case .basic:
            settings = ObjectSetting.allCases
        case .profile:
            settings = [.cover, .layout]
        }
    }
    
}
