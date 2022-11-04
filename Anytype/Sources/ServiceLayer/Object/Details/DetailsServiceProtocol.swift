//
//  DetailsServiceProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 22.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import SwiftProtobuf

protocol DetailsServiceProtocol {
        
    func updateBundledDetails(_ bundledDpdates: [BundledDetails])
    func updateBundledDetails(contextID: String, bundledDpdates: [BundledDetails])
    func setLayout(_ detailsLayout: DetailsLayout)
    func updateDetails(contextId: String, relationKey: String, value: Google_Protobuf_Value)
}
