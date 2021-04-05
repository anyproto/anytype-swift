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
    func empty() -> DetailsInformationModelProtocol
    func build(list: [Content]) -> DetailsInformationModelProtocol
    func build(information: DetailsInformationModelProtocol) -> DetailsInformationModelProtocol
}

extension Namespace {
    class Builder: DetailsInformationBuilderProtocol {
        typealias Model = InformationModel
        func empty() -> DetailsInformationModelProtocol {
            self.build(list: [])
        }
        func build(list: [Content]) -> DetailsInformationModelProtocol {
            Model.init(list)
        }
        func build(information: DetailsInformationModelProtocol) -> DetailsInformationModelProtocol {
            Model.init(information.details)
        }
    }
}
