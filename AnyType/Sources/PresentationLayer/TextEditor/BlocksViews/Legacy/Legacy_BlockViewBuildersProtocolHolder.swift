//
//  Legacy_BlockViewBuildersProtocolHolder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

#warning("DeveloperMessages.FileIsDeprecated")

@available(*, deprecated, message: "Deprecated protocol.")
protocol Legacy_BlockViewBuildersProtocolHolder {
    var builders: [BlockViewBuilderProtocol] {get set}
}
