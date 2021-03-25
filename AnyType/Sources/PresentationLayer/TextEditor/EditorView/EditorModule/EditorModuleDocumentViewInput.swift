//
//  EditorModuleDocumentViewInput.swift
//  AnyType
//
//  Created by Kovalev Alexander on 24.03.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

/// Input data for document view
protocol EditorModuleDocumentViewInput: AnyObject {
    
    /// Set focus
    ///
    /// - Parameter index: Block index
    func setFocus(at index: Int)
 
    /// Update data with new rows
    ///
    /// - Parameters:
    ///   - rows: Rows to display
    func updateData(_ rows: [BlocksViews.New.Base.ViewModel])
    
    /// Delete rows from view
    ///
    /// - Parameters:
    ///   - rows: Rows to delete
    func delete(rows: [BlocksViews.New.Base.ViewModel])
    
    /// Insert new rows after passed row, for example, for toggle open event
    ///
    /// - Parameters:
    ///   - rows: New rows to insert
    ///   - row: Row after wich to insert new rows
    func insert(rows: [BlocksViews.New.Base.ViewModel], after row: BlocksViews.New.Base.ViewModel)
}
