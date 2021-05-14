//
//  DocumentDetailsChildViewModel.swift
//  Anytype
//
//  Created by Konstantin Mordan on 13.05.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit.UIView

protocol DocumentDetailsChildViewModel {
    
    var detailsActiveModel: DetailsActiveModel { get }
    
    func makeView() -> UIView
    
}
