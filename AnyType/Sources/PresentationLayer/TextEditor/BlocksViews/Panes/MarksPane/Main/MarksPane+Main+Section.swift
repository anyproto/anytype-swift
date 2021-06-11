//
//  MarksPane+Main+Section.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

// MARK: Section
extension MarksPane.Main {
    enum Section {}
}

// MARK: Section / Category
extension MarksPane.Main.Section {
    enum Category {
        case style
        case textColor
        case backgroundColor
        
        func title() -> String { Resources.Title.title(for: self) }
    }
    enum Resources {
        struct Title {
            static func title(for category: Category) -> String {
                switch category {
                case .style: return "Style"
                case .textColor: return "Color"
                case .backgroundColor: return "Background"
                }
            }
        }
    }
}

// MARK: Section / ViewModel
extension MarksPane.Main.Section {
    class ViewModel: ObservableObject {
        var chosenCategory: Category {
            get {
                self.availableCategories[self.chosenIndex]
            }
            set {
                self.chosenIndex = self.availableCategories.firstIndex(of: newValue) ?? 0
            }
        }
        @Published var chosenIndex: Int = 0
        var availableCategories: [Category] = [.style, .textColor, .backgroundColor]
    }
}
