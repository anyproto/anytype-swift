//
//  BookmarkViewModelResource.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//
import Foundation

// MARK: - Resource
extension BookmarkViewModel {
    
    class Resource {
        
        let state: State
        var imageLoader: ImageLoader?
        
        required init(state: State) {
            self.state = state
        }
        
        enum State {
            case empty
            case onlyURL(Payload)
            case fetched(Payload)
        }
        
        struct Payload {
            let url: String?
            let title: String?
            let subtitle: String?
            let imageHash: String?
            let iconHash: String?
            
            func hasImage() -> Bool { !imageHash.isNil }
        }
        
                
        /// We could store images here, for example.
        /// Or we could update images directly.
        /// Or we could store images properties as @Published here.
        static func empty() -> Self {
            .init(state: .empty)
        }
        
        static func onlyURL(_ payload: Payload) -> Self {
            .init(state: .onlyURL(payload))
        }
        
        static func fetched(_ payload: Payload) -> Self {
            .init(state: .fetched(payload))
        }
    }
}

extension BookmarkViewModel.Resource {
    
    class ImageLoader {
        /// I want to subscribe on current value subject, lol.
        var imageProperty: ImageProperty?
        var iconProperty: ImageProperty?
        
        func subscribeImage(_ imageHash: String) {
            guard !imageHash.isEmpty else { return }
            
            imageProperty = ImageProperty(imageId: imageHash, .init(width: .default))
        }
        
        func subscribeIcon(_ iconHash: String) {
            guard !iconHash.isEmpty else { return }
            
            iconProperty = ImageProperty(imageId: iconHash, .init(width: .thumbnail))
        }
    }
    
}
