//
//  CommonViews+ImageView+Loader.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 15.12.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = CommonViews.ImageView

extension Namespace {
    class Loader {
        
        /// Variables
        private var subscription: AnyCancellable?
        private weak var imageView: UIImageView?
        private var property: CoreLayer.Network.Image.Property?
        
        /// Configuration
        func configured(_ imageView: UIImageView?) {
            self.imageView = imageView
        }
        
        /// Update
        func update(imageId hash: String, parameters: CoreLayer.Network.Image.ImageParameters = .init(width: .default)) {
            self.property = .init(imageId: hash, .init(width: .default))
            
            if let image = self.property?.property {
                self.imageView?.image = image
                return
            }
            
            self.imageView?.image = nil
            self.subscription = self.property?.stream.receive(on: RunLoop.main).sink { [weak self] (value) in
                self?.imageView?.image = value
                //                    self?.updateImageConstraints()
            }
        }
        
        /// Cleanup
        func cleanupSubscription() {
            self.subscription = nil
        }
    }
}


