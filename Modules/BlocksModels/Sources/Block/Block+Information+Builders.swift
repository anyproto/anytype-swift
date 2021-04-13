//
//  Block+Information+Builders.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 13.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation


public protocol BlockInformationBuilderProtocol {
    func build(id: BlockId, content: BlockContent) -> BlockInformation.InformationModel
    func build(information: BlockInformation.InformationModel) -> BlockInformation.InformationModel
}

extension BlockInformation {
    class Builder: BlockInformationBuilderProtocol {
        func build(id: BlockId, content: BlockContent) -> BlockInformation.InformationModel {
            InformationModel(id: id, content: content)
        }
        func build(information: BlockInformation.InformationModel) -> BlockInformation.InformationModel {
            InformationModel.init(information: information)
        }
    }
}
