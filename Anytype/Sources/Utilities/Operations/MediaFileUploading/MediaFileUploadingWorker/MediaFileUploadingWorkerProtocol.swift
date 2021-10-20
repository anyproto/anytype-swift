//
//  MediaFileUploadingWorkerProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 05.10.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

protocol MediaFileUploadingWorkerProtocol {
    
    var contentType: MediaPickerContentType { get }
    
    func cancel()
    func prepare()
    func upload(_ localPath: String)
    func finish()
    
}
