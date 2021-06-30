//
//  BookmarkViewModelContentConfiguration.swift
//  Anytype
//
//  Created by Konstantin Mordan on 20.06.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit
import BlocksModels

// MARK: ContentConfiguration
extension BookmarkViewModel {
    
    /// As soon as we have builder in this type ( makeContentView )
    /// We could map all states ( for example, image has several states ) to several different ContentViews.
    ///
    struct ContentConfiguration: UIContentConfiguration, Hashable {
        
        let information: BlockInformation
        
        weak var contextMenuHolder: BookmarkViewModel?
        
        init(_ information: BlockInformation) {
            switch information.content {
            case .bookmark: break
            default:
                assertionFailure("Can't create content configuration for content: \(information.content)")
                break
            }
            
            self.information = information
        }
                
        /// UIContentConfiguration
        func makeContentView() -> UIView & UIContentView {
            ContentView(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> ContentConfiguration {
            /// do something
            return self
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.information == rhs.information &&
                lhs.information.content == rhs.information.content
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(information)
            hasher.combine(information.content)
        }
        
    }
}
