//
//  DocumentModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

/// Model for document in workspace
struct DocumentModel {
	var data: Data? = nil
	var modificationDate: Date? = nil
	var name: String
	var imagePath: String? = nil
	var emojiImage: String? = nil
}
