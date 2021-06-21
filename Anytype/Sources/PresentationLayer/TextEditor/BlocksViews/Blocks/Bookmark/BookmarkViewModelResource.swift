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
        
        class ImageLoader {
            /// I want to subscribe on current value subject, lol.
            var imageProperty: ImageProperty?
            var iconProperty: ImageProperty?
            func resetImages() {
//                self.imageProperty = nil
//                self.iconProperty = nil
            }
            func subscribeImage(_ payload: Payload.Image?) {
                guard let image = payload else { return }
                if let hash = image.hash {
                    self.imageProperty = .init(imageId: hash, .init(width: .default))
                }
            }
            func subscribeIcon(_ payload: Payload.Image?) {
                guard let image = payload else { return }
                if let hash = image.hash {
                    self.iconProperty = .init(imageId: hash, .init(width: .thumbnail))
                }
            }
        }
        
        struct Payload {
            struct Image {
                var hash: String?
                var url: URL?
                var data: Data?
            }
            var url: String?
            var title: String?
            var subtitle: String?
            var image: Image?
            var icon: Image?
            
            func hasImage() -> Bool { !self.image.isNil }
            func hasIcon() -> Bool { !self.icon.isNil }
        }
        enum State {
            case empty
            case onlyURL(Payload)
            case fetched(Payload)
        }
        
        required init(state: State) { self.state = state }
        
        var state: State
        var imageLoader: ImageLoader?
        
        func update(_ imageLoader: ImageLoader?) {
            self.imageLoader = imageLoader
        }
                
        /// We could store images here, for example.
        /// Or we could update images directly.
        /// Or we could store images properties as @Published here.
        static func empty() -> Self { .init(state: .empty) }
        static func onlyURL(_ payload: Payload) -> Self { .init(state: .onlyURL(payload)) }
        static func fetched(_ payload: Payload) -> Self { .init(state: .fetched(payload)) }
    }
}
