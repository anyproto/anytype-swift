//
//  BookmarkViewModelResourceConverter.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import BlocksModels

// MARK: - State Converter
extension BookmarkViewModel {
    
    enum ResourceConverter {
        
        static func asModel(_ value: Resource) -> BlockContent.Bookmark? {
            return nil
        }
        
        static func asOurModel(_ value: BlockContent.Bookmark) -> Resource? {
            if value.url.isEmpty {
                return .empty()
            }
            
            if value.title.isEmpty {
                return .onlyURL(
                    .init(
                        url: value.url,
                        title: value.title,
                        subtitle: value.theDescription,
                        image: .init(
                            hash: value.imageHash,
                            url: nil,
                            data: nil
                        ),
                        icon: .init(
                            hash: value.faviconHash,
                            url: nil,
                            data: nil
                        )
                    )
                )
            }
            
            return .fetched(
                .init(
                    url: value.url,
                    title: value.title,
                    subtitle: value.theDescription,
                    image: .init(
                        hash: value.imageHash,
                        url: nil,
                        data: nil
                    ),
                    icon: .init(
                        hash: value.faviconHash,
                        url: nil,
                        data: nil
                    )
                )
            )
        }
    }
    
}
