//
//  RelationSheetViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import AnytypeCore
import SwiftUI

final class RelationSheetViewModel: ObservableObject {
    
    let name: String
    let contentViewModel: RelationEditingViewModelProtocol
    
    private(set) var onDismiss: (() -> Void)?
    
    init(name: String, contentViewModel: RelationEditingViewModelProtocol) {
        self.name = name
        self.contentViewModel = contentViewModel
    }
    
    func configureOnDismiss(_ onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
}
