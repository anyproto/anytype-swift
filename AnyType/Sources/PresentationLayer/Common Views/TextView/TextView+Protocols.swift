//
//  TextView+Protocols.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 31.01.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

protocol TextViewUserInteractionProtocol: class {
    func didReceiveAction(_ action: TextView.UserAction)
}
