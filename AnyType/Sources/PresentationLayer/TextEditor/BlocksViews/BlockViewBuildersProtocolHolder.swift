//
//  BlockViewBuildersProtocolHolder.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

protocol BlockViewBuildersProtocolHolder {
    var builders: [BlockViewBuilderProtocol] {get set}
}
