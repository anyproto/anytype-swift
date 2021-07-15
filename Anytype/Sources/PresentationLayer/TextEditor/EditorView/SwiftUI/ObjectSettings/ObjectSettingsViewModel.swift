//
//  ObjectSettingsViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 14.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Combine

final class ObjectSettingsViewModel: ObservableObject {
    
    @Published private(set) var settings: [ObjectSetting] = ObjectSetting.allCases
    
    
}
