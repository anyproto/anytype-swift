//
//  Block+Information+Builders.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 13.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Block.Information

public protocol BlockInformationBuilderProtocol {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Content = TopLevel.AliasesMap.BlockContent
    func build(id: BlockId, content: Content) -> Block.Information.InformationModel
    func build(information: Block.Information.InformationModel) -> Block.Information.InformationModel
}

extension Namespace {
    class Builder: BlockInformationBuilderProtocol {
        typealias Model = InformationModel
        func build(id: BlockId, content: Content) -> Block.Information.InformationModel {
            Model.init(id: id, content: content)
        }
        func build(information: Block.Information.InformationModel) -> Block.Information.InformationModel {
            Model.init(information: information)
        }
    }
}
