//
//  ObjectHeaderImageUsecase.swift
//  Anytype
//
//  Created by Konstantin Mordan on 05.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import AnytypeCore

enum ObjectHeaderImageUsecase {
    case icon
    case cover
}

extension ObjectHeaderImageUsecase {
    
    var notificationName: Notification.Name {
        switch self {
        case .icon:
            return .documentIconImageUploadingEvent
        case .cover:
            return .documentCoverImageUploadingEvent
        }
    }
    
    func updatedDetails(with imageHash: Hash) -> ObjectRawDetails {
        switch self {
        case .icon:
            return [.iconEmoji(""), .iconImageHash(imageHash)]
        case .cover:
            return [.coverType(CoverType.uploadedImage), .coverId(imageHash.value)]

        }
    }
    
}
