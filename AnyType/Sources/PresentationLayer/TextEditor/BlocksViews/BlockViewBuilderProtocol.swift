//
//  BlockViewBuilderProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 09.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

/// Define builder for block view in the block's view list
protocol BlockViewBuilderProtocol {
    var id: Block.ID { get }
    
    func buildView() -> AnyView    
}
