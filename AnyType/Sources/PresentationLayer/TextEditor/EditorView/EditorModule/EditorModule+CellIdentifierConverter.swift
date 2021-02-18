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
    static func identifier(for builder: BlocksViews.New.Base.ViewModel) -> String? {
        switch builder.getBlock().blockModel.information.content {
        case let .text(text) where text.contentType == .text:
            return EditorModule.Document.Cells.ContentConfigurations.Text.Text.Table.cellReuseIdentifier()
        case let .file(file) where file.contentType == .file:
            return EditorModule.Document.Cells.ContentConfigurations.File.File.Table.cellReuseIdentifier()
        case let .file(file) where file.contentType == .image:
            return EditorModule.Document.Cells.ContentConfigurations.File.Image.Table.cellReuseIdentifier()
        case .bookmark:
            return EditorModule.Document.Cells.ContentConfigurations.Bookmark.Bookmark.Table.cellReuseIdentifier()
        case .divider:
            return EditorModule.Document.Cells.ContentConfigurations.Other.Divider.Table.cellReuseIdentifier()
        case let .link(value) where value.style == .page:
            return EditorModule.Document.Cells.ContentConfigurations.Link.PageLink.Table.cellReuseIdentifier()
        default:
            assertionFailure("Builder with unknown content passed")
            return nil
        }
    }
}
