//
//  UTTypeExtension.swift
//  Anytype
//
//  Created by Denis Batvinkin on 22.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import UniformTypeIdentifiers

extension UTType {
    //Word documents
    static var docx: UTType {
        UTType.types(tag: "docx", tagClass: .filenameExtension, conformingTo: nil).first!
    }

    static var doc: UTType {
        UTType.types(tag: "doc", tagClass: .filenameExtension, conformingTo: nil).first!
    }

    static var csv: UTType {
        UTType.types(tag: "csv", tagClass: .filenameExtension, conformingTo: nil).first!
    }

    static var flac: UTType {
        UTType.types(tag: "audio/x-flac", tagClass: .mimeType, conformingTo: .audio).first!
    }

    static var xls: UTType {
        UTType.types(tag: "xls", tagClass: .filenameExtension, conformingTo: nil).first!
    }

    static var xlsx: UTType {
        UTType.types(tag: "xlsx", tagClass: .filenameExtension, conformingTo: nil).first!
    }

    static var anySlot: UTType {
        UTType("com.anytype.anySlots")!
    }
}
