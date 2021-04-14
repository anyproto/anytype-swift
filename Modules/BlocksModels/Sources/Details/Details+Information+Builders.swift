//
//  Details+Information+Builders.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 13.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation

fileprivate typealias Namespace = Details.Information

public protocol DetailsInformationBuilderProtocol {
    typealias Content = DetailsContent
    func empty() -> DetailsInformationModel
    func build(list: [Content]) -> DetailsInformationModel
    func build(information: DetailsInformationModel) -> DetailsInformationModel
}

extension Namespace {
    class Builder: DetailsInformationBuilderProtocol {
        typealias Model = InformationModel
        func empty() -> DetailsInformationModel {
            self.build(list: [])
        }
        func build(list: [Content]) -> DetailsInformationModel {
            Model.init(list)
        }
        func build(information: DetailsInformationModel) -> DetailsInformationModel {
            Model.init(information.details)
        }
    }
}
