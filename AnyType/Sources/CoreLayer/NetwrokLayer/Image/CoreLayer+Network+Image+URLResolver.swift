//
//  CoreLayer+Network+Image+URLResolver.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.10.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import URLComponentsCoder

fileprivate typealias Namespace = CoreLayer.Network.Image

// MARK: - URLResolver
extension Namespace {
    struct URLResolver {
        private let configurationService: ConfigurationServiceProtocol = MiddlewareConfigurationService.init()
        private let subpath = "/image/"
        
        private func imageURL(configuration: MiddlewareConfigurationService.MiddlewareConfiguration, subpath: String, parameters: ImageParameters?) -> URL? {
            guard !subpath.isEmpty else { return nil }
            
            let string = configuration.gatewayURL + self.subpath + subpath
            
            /// Get components.
            var components = URLComponents(string: string)
            if let parameters = parameters {
                components?.queryItems = try? TopLevel.AliasesMap.Encoder.init().encode(parameters)
            }
            
            return components?.url
        }

        func transform(imageId: String, _ parameters: ImageParameters? = nil) -> AnyPublisher<URL?, Error> {
            self.configurationService.obtainConfiguration().map({self.imageURL(configuration: $0, subpath: imageId, parameters: parameters)}).eraseToAnyPublisher()
        }
    }
}
