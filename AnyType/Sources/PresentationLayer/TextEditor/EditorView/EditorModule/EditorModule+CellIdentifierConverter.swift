//
//  EditorModule+CellConverter.swift
//  AnyType
//
//  Created by Kovalev Alexander on 12.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

/// Entity to convert block view model type to cell reuse identifier
enum EditorModuleCellIdentifierConverter {

    /// Convert block content type to cell reuse identifier
    ///
    /// - Parameters:
    ///   - builder: Block view model
    /// - Returns: Cell reuse identifier
    static func identifier(for builder: BlocksViews.New.Base.ViewModel) -> String {
        switch builder.getBlock().blockModel.information.content {
        case let .text(text):
        switch text.contentType {
        case .text:
            return EditorModule.Document.Cells.ContentConfigurations.Text.Text.Collection.cellReuseIdentifier()
        case .quote:
            return EditorModule.Document.Cells.ContentConfigurations.Text.Quote.Collection.cellReuseIdentifier()
        case .bulleted:
            return EditorModule.Document.Cells.ContentConfigurations.Text.Bulleted.Collection.cellReuseIdentifier()
        case .checkbox:
            return EditorModule.Document.Cells.ContentConfigurations.Text.Checkbox.Collection.cellReuseIdentifier()
        case .numbered:
            return EditorModule.Document.Cells.ContentConfigurations.Text.Numbered.Collection.cellReuseIdentifier()
        case .toggle:
            return EditorModule.Document.Cells.ContentConfigurations.Text.Toggle.Collection.cellReuseIdentifier()
        default:
            return EditorModule.Document.Cells.ContentConfigurations.Unknown.Label.Collection.cellReuseIdentifier()
        }
        case let .file(file) where file.contentType == .file:
            return EditorModule.Document.Cells.ContentConfigurations.File.File.Collection.cellReuseIdentifier()
        case let .file(file) where file.contentType == .image:
            return EditorModule.Document.Cells.ContentConfigurations.File.Image.Collection.cellReuseIdentifier()
        case .bookmark:
            return EditorModule.Document.Cells.ContentConfigurations.Bookmark.Bookmark.Collection.cellReuseIdentifier()
        case .divider:
            return EditorModule.Document.Cells.ContentConfigurations.Other.Divider.Collection.cellReuseIdentifier()
        case let .link(value) where value.style == .page:
            return EditorModule.Document.Cells.ContentConfigurations.Link.PageLink.Collection.cellReuseIdentifier()
        default:
            return EditorModule.Document.Cells.ContentConfigurations.Unknown.Label.Collection.cellReuseIdentifier()
        }
    }
}
