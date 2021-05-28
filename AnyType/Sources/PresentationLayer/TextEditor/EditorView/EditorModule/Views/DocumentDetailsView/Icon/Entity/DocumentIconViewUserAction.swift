//
//  DocumentIconViewUserAction.swift
//  Anytype
//
//  Created by Konstantin Mordan on 17.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit.UIImage

enum DocumentIconViewUserAction: CaseIterable {
    case select
    case random
    case upload
    case remove
}

extension DocumentIconViewUserAction {
    
    var title: String {
        switch self {
        case .select:
            return "Choose emoji".localized
        case .random:
            return "Pick emoji randomly".localized
        case .upload:
            return "Upload photo".localized
        case .remove:
            return "Remove".localized
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .select:
            return UIImage(named: "Emoji/ContextMenu/choose")
        case .random:
            return UIImage(named: "Emoji/ContextMenu/random")
        case .upload:
            return UIImage(named: "Emoji/ContextMenu/upload")
        case .remove:
            return UIImage(named: "Emoji/ContextMenu/remove")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
}
