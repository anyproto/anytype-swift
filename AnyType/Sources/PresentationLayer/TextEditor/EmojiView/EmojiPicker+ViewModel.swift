//
//  EmojiPickerViewModel.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 4/27/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine
import SwiftProtobuf

extension EmojiPicker  {

    class ViewModel: ObservableObject {
        
        struct SearchResult {
            var notFound: Bool
            var keyword: String
        }
        
        typealias Emoji = EmojiPicker.Manager.Emoji
        typealias Category =  EmojiPicker.Manager.Category
        
        @Published var searchResult: SearchResult = .init(notFound: false, keyword: "")
        @Published var selectedEmoji: Emoji?
        
        var userEventSubject: PassthroughSubject<UserEvent, Never> = .init()
        
        public var emojisGrouped: [Category: [Emoji]] = [:]
        
        private let emojiManager =  EmojiPicker.Manager()
        
        init() {
            self.setupDefaultGroup()
        }
        
        private func setupDefaultGroup() {
            let list = emojiManager.emojis
            // Create dictionary with grouped value by 'category'
            self.updateGroup(with: list)
        }
        
        private func updateGroup(with list: [Emoji]) {
            emojisGrouped = .init(grouping: list, by: { $0.category })
        }
        
        public func filterEmojies(with keyword: String) {
            if keyword.count == 0 {
                setupDefaultGroup()
            }
            else {
                let list = emojiManager.emojis(keywords: [keyword])
                updateGroup(with: list)
            }
            
            searchResult = .init(notFound: emojisGrouped.isEmpty, keyword: keyword)
        }
        
    }
    
}

// MARK: - CollectionView datasource
extension EmojiPicker.ViewModel {
    
    func numberOfSections() -> Int {
        emojisGrouped.count
    }

    func countOfElements(at: Int) -> Int {
        let category = Category.allCases[at]
        return emojisGrouped[category]?.count ?? 0
    }

    func element(at: IndexPath) -> Emoji? {
        let category = Category.allCases[at.section]
        let emojies = emojisGrouped[category]
        return emojies?[at.row]
    }
    
    func sectionTitle(at: IndexPath) -> String {
        let category = Category.allCases[at.section]
        return category.rawValue
    }

}

// MARK: - CollectionView Delegate
extension EmojiPicker.ViewModel {

    func didSelectItem(at: IndexPath) {
        if let item = self.element(at: at) {
            self.selectedEmoji = item
            self.userEventSubject.send(.shouldDismiss)
        }
    }
    
}

// MARK: - UserEvent
extension EmojiPicker.ViewModel {
    enum UserEvent {
        case shouldDismiss
    }
}
