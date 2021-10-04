//
//  BlockImageUploader.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

final class BlockImageUploader: FileUploaderProtocol {
    
    let contentType: MediaPickerContentType = .images
    
    func uploadFileAt(localPath: String) -> Hash? {
        return nil
    }

}
