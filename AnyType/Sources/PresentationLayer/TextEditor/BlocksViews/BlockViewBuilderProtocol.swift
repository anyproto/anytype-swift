//
//  BlockViewBuilderProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 09.10.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI

/// Define builder for block view in the block's view list
protocol BlockViewBuilderProtocol: class {
    typealias Model = BlockModels.Block.RealBlock
    typealias IndexID = BusinessBlock.Index
    typealias BlockID = MiddlewareBlockInformationModel.Id
    
    var id: IndexID { get }
    var blockId: BlockID { get }
    
    func buildView() -> AnyView
    func buildUIView() -> UIView
}
