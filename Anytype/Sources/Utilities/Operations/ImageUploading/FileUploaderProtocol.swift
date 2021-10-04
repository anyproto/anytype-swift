//
//  FileUploaderProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 04.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

protocol FileUploaderProtocol {
    
    var contentType: MediaPickerContentType { get }
    
    func uploadFileAt(localPath: String) -> Hash?
    
}
