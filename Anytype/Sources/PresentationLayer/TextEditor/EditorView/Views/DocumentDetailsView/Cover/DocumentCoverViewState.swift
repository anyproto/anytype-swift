//
//  DocumentCoverViewState.swift
//  Anytype
//
//  Created by Konstantin Mordan on 01.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UIKit.UIImage

enum DocumentCoverViewState: Hashable {
    case cover(DocumentCover)
    case preview(UIImage?)
    case empty
}
