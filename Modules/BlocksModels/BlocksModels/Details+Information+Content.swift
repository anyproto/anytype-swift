//
//  Details+Information+Content.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let pageDetails: Self = "BlocksModels.Block.Information.PageDetails"
}

fileprivate typealias Namespace = Details.Information

// MARK: Content
public extension Namespace {
    enum Content {
        case title(Title)
        case iconEmoji(Emoji)
    }
}

// MARK: Content / Properties
public extension Namespace.Content {
    /// This function returns an id for a `case`.
    /// This key we use for middleware details keys and also we use it to store our details in `[String : Content]` above in PageDetails.
    /// But it is still a key.
    ///
    /// - Returns: A key.
    func id() -> String {
        switch self {
        case .title: return Title.id
        case .iconEmoji: return Emoji.id
        }
    }
    
    /// This is "likeness" `id` that `erases associated value` of enum.
    /// We need it as id in dictionaries.
    ///
    func kind() -> Kind {
        switch self {
        case .title: return .title
        case .iconEmoji: return .iconEmoji
        }
    }
}

// MARK: DetailsMatching
// TODO: Rethink later. It should be done via Keys.
public extension Namespace.Content {
    /// Actually, we could done this in the same way as EnvironemntKey and EnvironmentValues.
    enum Kind {
        case title
        case iconEmoji
    }
}

// MARK: Protocols
private protocol DetailsEntryIdentifiable {
    associatedtype ID
    static var id: ID {get}
}

// MARK: Content / Title
public extension Namespace.Content {
    /// It is a custom detail.
    /// This detail refers to a `Title` that is coming in middleware `details`.
    /// Its id has value "name".
    /// But, it is doc, so, make sure that you use correct id if something goes wrong.
    ///
    struct Title {
        public private(set) var text: String = ""
        public private(set) var id: String = Self.id
        
        // MARK: - Memberwise initializer
        /// We should explicitly provide public access level to memberwise initializer.
        public init(text: String = "", id: String = Self.id) {
            self.text = text
            self.id = id
        }
    }
}

// MARK: Content / Title / Key
extension Namespace.Content.Title: DetailsEntryIdentifiable {
    public static var id: String = "name"
}

// MARK: Content / IconEmoji
public extension Namespace.Content {
    struct Emoji {
        public private(set) var text: String = ""
        public private(set) var id: String = Self.id

        // MARK: - Memberwise initializer
        public init(text: String = "", id: String = Self.id) {
            self.text = text
            self.id = id
        }
    }
}

// MARK: Content / IconEmoji

// MARK: Content / IconEmoji / Key
extension Namespace.Content.Emoji: DetailsEntryIdentifiable {
    public static var id: String = "iconEmoji"
}

// MARK: Hashable
extension Namespace.Content: Hashable {}
extension Namespace.Content.Title: Hashable {}
extension Namespace.Content.Emoji: Hashable {}
