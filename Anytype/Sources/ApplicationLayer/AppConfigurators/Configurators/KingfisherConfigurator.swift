//
//  KingfisherConfigurator.swift
//  Anytype
//
//  Created by Konstantin Mordan on 21.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Kingfisher

final class KingfisherConfigurator: AppConfiguratorProtocol {
    
    func configure() {
        KingfisherManager.shared.defaultOptions = [
            .cacheOriginalImage,
            .originalCache(Kingfisher.ImageCache.originalImagesCache),
            .backgroundDecode,
            .diskCacheExpiration(.days(3))
        ]
    }
    
}
