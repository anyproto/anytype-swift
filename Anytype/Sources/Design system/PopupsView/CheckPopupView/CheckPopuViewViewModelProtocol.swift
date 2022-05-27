//
//  CheckPopuViewViewModelProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 01.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import SwiftUI

protocol CheckPopuViewViewModelProtocol: ObservableObject {
    var items: [CheckPopupItem] { get }

    func onTap(itemId: String)
}
