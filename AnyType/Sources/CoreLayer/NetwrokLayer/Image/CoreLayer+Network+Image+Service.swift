//
//  CoreLayer+Network+Image+Service.swift
//  AnyType
//
//  Created by Denis Batvinkin on 20.08.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import UIKit

fileprivate typealias Namespace = CoreLayer.Network.Image

extension Namespace {
    final class Service {
        func fetchImage(url: URL) -> AnyPublisher<UIImage?, Error> {
            URLSession.shared.dataTaskPublisher(for: url).map({UIImage(data: $0.data)})
                .mapError({$0}) // Bug?
                .eraseToAnyPublisher()
        }
        
        func fetchImageAndIgnoreError(url: URL) -> AnyPublisher<UIImage?, Never> {
            self.fetchImage(url: url).ignoreFailure().eraseToAnyPublisher()
        }
    }
}
