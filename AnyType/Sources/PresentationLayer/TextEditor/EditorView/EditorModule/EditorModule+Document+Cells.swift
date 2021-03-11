//
//  EditorModule+Document+Cells.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.12.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

fileprivate typealias DocumentNamespace = EditorModule.Document
fileprivate typealias Namespace = DocumentNamespace.Cells

extension DocumentNamespace {
    enum Cells {}
}

// MARK: - New Cells
extension Namespace {
    enum ContentConfigurations {
        class Collection: UICollectionViewListCell {
            
            private enum Constants {
                static let indentationWidth: CGFloat = 24
            }
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                self.indentationWidth = Constants.indentationWidth
            }
            
            required init?(coder: NSCoder) {
                super.init(coder: coder)
                self.indentationWidth = Constants.indentationWidth
            }
            
            override func updateConfiguration(using state: UICellConfigurationState) {
                super.updateConfiguration(using: state)
                self.setNeedsUpdateConstraints()
                self.setNeedsLayout()
            }
        }
    }
}

fileprivate typealias ContentConfigurationsCells = Namespace.ContentConfigurations

// MARK: ContentConfigurations
extension ContentConfigurationsCells {
    enum Text {}
    enum File {}
    enum Bookmark {}
    enum Other {}
    enum Link {}
    enum Unknown {}
}

// MARK: ContentConfigurations / Text
extension ContentConfigurationsCells.Text {
    enum Text {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
    
    enum Quote {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
    
    enum Checkbox {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
    
    enum Numbered {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
    
    enum Bulleted {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
    
    enum Toggle {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
}

// MARK: ContentConfigurations / Files
extension ContentConfigurationsCells.File {
    enum File {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
    enum Image {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
}

// MARK: ContentConfigurations / Bookmark
extension ContentConfigurationsCells.Bookmark {
    enum Bookmark {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
}

// MARK: ContentConfigurations / Divider
extension ContentConfigurationsCells.Other {
    enum Divider {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
}

// MARK: ContentConfigurations / Link
extension ContentConfigurationsCells.Link {
    enum PageLink {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
}

// MARK: ContentConfigurations / Unknown
extension ContentConfigurationsCells.Unknown {
    enum Label {
        final class Collection: EditorModule.Document.Cells.ContentConfigurations.Collection {}
    }
}
