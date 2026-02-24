import Foundation

// MARK: - Identifiable Wrappers for Sheet Presentation
//
// SwiftUI's sheet(item:) requires Identifiable types.
// Use these wrappers instead of creating custom structs for single-value presentations.
//
// Usage:
//   var sheetData: URLIdentifiable?
//   sheetData = url.identifiable
//   .sheet(item: $sheetData) { QrCodeView(url: $0.value) }
//
// See IOS_DEVELOPMENT_GUIDE.md for details.

// For show modules with one String arg
struct StringIdentifiable: Identifiable {
    
    let value: String
    
    init(value: String) {
        self.value = value
    }
    
    var id: String { value }
}

extension String {
    var identifiable: StringIdentifiable {
        StringIdentifiable(value: self)
    }
}

// For show modules with one Int arg
struct IntIdentifiable: Identifiable {
    
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    var id: Int { value }
}

extension Int {
    var identifiable: IntIdentifiable {
        IntIdentifiable(value: self)
    }
}

// For show modules with one Data arg
struct DataIdentifiable: Identifiable {
    
    let value: Data
    
    init(value: Data) {
        self.value = value
    }
    
    var id: Int { value.hashValue }
}

extension Data {
    var identifiable: DataIdentifiable {
        DataIdentifiable(value: self)
    }
}

// For show modules with one URL arg
struct URLIdentifiable: Identifiable {

    let value: URL

    init(value: URL) {
        self.value = value
    }

    var id: String { value.absoluteString }
}

extension URL {
    var identifiable: URLIdentifiable {
        URLIdentifiable(value: self)
    }
}
