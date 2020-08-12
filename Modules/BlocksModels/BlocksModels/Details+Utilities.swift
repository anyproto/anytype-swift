//
//  Details+Utilities.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Details

public extension Namespace {
    enum Utilities {}
}

public extension Namespace.Utilities {
    struct InformationAccessor {
        public typealias T = DetailsInformationModelProtocol
        public typealias Content = TopLevel.AliasesMap.DetailsContent
        private var value: T
        
        public var title: Content.Title? {
            switch self.value.details[Content.Title.id] {
            case let .title(value): return value
            default: return nil
            }
        }
        
        public var iconEmoji: Content.Emoji? {
            switch self.value.details[Content.Emoji.id] {
            case let .iconEmoji(value): return value
            default: return nil
            }
        }
        
        public var iconColor: Content.OurHexColor? {
            switch self.value.details[Content.OurHexColor.id] {
            case let .iconColor(value): return value
            default: return nil
            }
        }
        
        public var iconImage: Content.ImageId? {
            switch self.value.details[Content.ImageId.id] {
            case let .iconImage(value): return value
            default: return nil
            }
        }
        
        // MARK: - Memberwise Initializer
        public init(value: T) {
            self.value = value
        }
    }
}
