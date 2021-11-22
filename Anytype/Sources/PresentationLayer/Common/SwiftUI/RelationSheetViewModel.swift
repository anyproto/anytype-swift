//
//  RelationSheetViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 19.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class RelationSheetViewModel: ObservableObject {
    
    private(set) var onDismiss: (() -> Void)?
    
    func configureOnDismiss(_ onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
}
