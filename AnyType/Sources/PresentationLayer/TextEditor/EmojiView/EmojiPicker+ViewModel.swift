//
//  EmojiPickerViewModel.swift
//  AnyType
//
//  Created by Valentine Eyiubolu on 4/27/20.
//  Copyright © 2020 AnyType. All rights reserved.
//

import UIKit
import Combine

extension EmojiPicker  {

    class ViewModel: ObservableObject {
        
        struct SearchResult {
            let notFound: Bool
            let keyword: String
        }
                
        @Published var searchResult = SearchResult(notFound: false, keyword: "")
        @Published var selectedEmoji: Emoji?
        
        var userEventSubject: PassthroughSubject<UserEvent, Never> = .init()

        private let emojiProvider = EmojiProvider.shared

        private var emojiGroups: [EmojiGroup] = []
                        
        init() {
            self.setupDefaultGroup()
        }
        
        private func setupDefaultGroup() {
            self.emojiGroups = emojiProvider.emojiGroups
        }
        
        public func filterEmojies(with keyword: String) {
            if keyword.count == 0 {
                setupDefaultGroup()
            } else {
                let list = emojiProvider.filteredEmojiGroups(keyword: keyword)
                self.emojiGroups = list
            }
            
            searchResult = SearchResult(notFound: emojiGroups.isEmpty, keyword: keyword)
        }
        
    }
    
}

// MARK: - CollectionView datasource
extension EmojiPicker.ViewModel {
    
    func numberOfSections() -> Int {
        emojiGroups.count
    }

    func countOfElements(at index: Int) -> Int {
        emojiGroups[safe: index]?.emojis.count ?? 0
    }

    func element(at indexPath: IndexPath) -> Emoji? {
        emojiGroups[safe: indexPath.section]?.emojis[safe: indexPath.row]
    }
    
    func sectionTitle(at indexPath: IndexPath) -> String {
        guard let title = emojiGroups[safe: indexPath.section]?.name else {
            return ""
        }
        return title
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
