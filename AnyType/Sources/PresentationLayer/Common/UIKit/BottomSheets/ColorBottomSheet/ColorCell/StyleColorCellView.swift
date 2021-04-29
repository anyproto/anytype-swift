//
//  StyleColorCellView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 27.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class StyleColorCellView: UICollectionViewCell {

    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundConfiguration = UIBackgroundConfiguration.listPlainCell()
        backgroundConfiguration?.backgroundColor = .clear
    }
}
