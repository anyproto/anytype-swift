//
//  DetailsInformationProviderExtensions.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels

extension DetailsInformationProvider {
    
    var documentIcon: DocumentIcon? {
        if let iconImageId = self.iconImage?.value, !iconImageId.isEmpty {
            return DocumentIcon.image(iconImageId)
        }
        
        if let iconEmoji = IconEmoji(self.iconEmoji?.value) {
            return DocumentIcon.emoji(iconEmoji)
        }
        
        return nil
    }
    
}
