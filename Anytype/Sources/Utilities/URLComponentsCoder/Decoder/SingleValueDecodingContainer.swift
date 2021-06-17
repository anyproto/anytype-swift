import Foundation

final class URLComponentsDecoderSingleValueContainer {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var data: [URLQueryItem] = []
    
    var currentCodingPathKeyString: String {
        self.codingPath.map(\.stringValue).joined(separator: ".")
    }
    
    init(data: [URLQueryItem], codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
}

extension URLComponentsDecoderSingleValueContainer: SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        let current = self.currentCodingPathKeyString
        return self.data.first(where: {$0.name == current})?.value == nil
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        let current = self.currentCodingPathKeyString
        guard let value = self.data.first(where: {$0.name == current})?.value else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't find item with path \(current) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        guard let result = type.init(value) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't decode to type \(type) value \(value) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        return result
    }
    
    func decode(_ type: String.Type) throws -> String {
        let current = self.currentCodingPathKeyString
        guard let value = self.data.first(where: {$0.name == current})?.value else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't find item with path \(current) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        return value
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        let current = self.currentCodingPathKeyString
        guard let value = self.data.first(where: {$0.name == current})?.value else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't find item with path \(current) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        guard let result = type.init(value) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't decode to type \(type) value \(value) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        return result
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        let current = self.currentCodingPathKeyString
        guard let value = self.data.first(where: {$0.name == current})?.value else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't find item with path \(current) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        guard let result = type.init(value) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't decode to type \(type) value \(value) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        return result
    }
    
    private func decode<T>(type: T.Type) throws -> T where T: FixedWidthInteger & SignedInteger {
        let current = self.currentCodingPathKeyString
        guard let value = self.data.first(where: {$0.name == current})?.value else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't find item with path \(current) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        guard let result = type.init(value) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't decode to type \(type) value \(value) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        return result
    }
    
    private func decode<T>(type: T.Type) throws -> T where T: FixedWidthInteger & UnsignedInteger {
        let current = self.currentCodingPathKeyString
        guard let value = self.data.first(where: {$0.name == current})?.value else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't find item with path \(current) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        guard let result = type.init(value) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Can't decode to type \(type) value \(value) in data \(self.data)")
            throw DecodingError.dataCorrupted(context)
        }
        return result
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        try self.decode(type: type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try self.decode(type: type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try self.decode(type: type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try self.decode(type: type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try self.decode(type: type)
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        try self.decode(type: type)
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try self.decode(type: type)
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try self.decode(type: type)
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try self.decode(type: type)
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try self.decode(type: type)
    }
  
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let decoder = URLComponentsDecoder()
        return try decoder.decode(type, from: self.data)
    }
}

extension URLComponentsDecoderSingleValueContainer: URLComponentsDecodingContainer {}
