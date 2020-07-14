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
            if case let .title(title) = self.value.details[Content.Title.id] {
                return title
            }
            return nil
        }
        
        public var iconEmoji: Content.Emoji? {
            if case let .iconEmoji(emoji) = self.value.details[Content.Emoji.id] {
                return emoji
            }
            return nil
        }
        
        // MARK: - Memberwise Initializer
        public init(value: T) {
            self.value = value
        }
    }
}
