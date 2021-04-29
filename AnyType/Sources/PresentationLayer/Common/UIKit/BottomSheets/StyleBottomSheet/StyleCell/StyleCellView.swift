//
//  StyleCellView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 23.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


final class StyleCellView: UICollectionViewCell {

    override func updateConfiguration(using state: UICellConfigurationState) {
        backgroundConfiguration = StyleCellBackgroundConfiguration.configuration(for: state)
    }
}
