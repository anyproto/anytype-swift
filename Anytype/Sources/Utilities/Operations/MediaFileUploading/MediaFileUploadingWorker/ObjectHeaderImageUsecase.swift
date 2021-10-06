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
    
    func updatedDetails(with imageHash: Hash) -> RawDetailsData {
        switch self {
        case .icon:
            return [
                .iconEmoji: DetailsEntry(value: ""),
                .iconImage: DetailsEntry(value: imageHash.value)
            ]
        case .cover:
            return [
                .coverType: DetailsEntry(value: CoverType.uploadedImage),
                .coverId: DetailsEntry(value: imageHash.value)
            ]
        }
    }
    
}
