//
//  ObjectIconPickerViewModelProtocol.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 12.04.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

protocol ObjectIconPickerViewModelProtocol {
    var mediaPickerContentType: MediaPickerContentType { get }
    var isRemoveButtonAvailable: Bool { get }

    func setEmoji(_ emojiUnicode: String)
    func uploadImage(from itemProvider: NSItemProvider)
    func removeIcon()
}
