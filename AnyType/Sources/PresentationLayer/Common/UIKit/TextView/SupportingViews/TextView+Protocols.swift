//
//  TextView+Protocols.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 31.01.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

protocol TextViewUserInteractionProtocol: AnyObject {
    func didReceiveAction(_ action: CustomTextView.UserAction)
}
