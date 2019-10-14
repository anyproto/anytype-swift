//
//  BlockViewRowBuilderProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 09.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

/// Define builder for concrete block view in the block's view list
protocol BlockViewRowBuilderProtocol {
    var id: UUID { get }
    func buildView() -> AnyView    
}
