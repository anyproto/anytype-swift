import Foundation

final class URLComponentsDecoderUnkeyedContainer {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var data: [URLQueryItem] = []
    
    var currentIndex: Int = 0
    var nestedContainers: [URLComponentsDecodingContainer] = []
    var count: Int? { self.nestedContainers.count }
    var isAtEnd: Bool {
        guard let count = self.count else {
            return true
        }
        return self.currentIndex >= count
    }
    
    init(data: [URLQueryItem], codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    private func append(_ item: URLQueryItem) {
        let index = self.currentIndex
        let nestedCodingPath: [CodingKey] = self.codingPath + [AnyCodingKey(intValue: index)!]
        self.nestedContainers.append(URLComponentsDecoderSingleValueContainer(data: self.data, codingPath: nestedCodingPath, userInfo: self.userInfo))
        self.currentIndex += 1
    }
    func process() {
        if (self.codingPath.isEmpty) {
            /// Match all keys
            self.data.forEach(self.append(_:))
        }
        else {
            let prefix = self.codingPath.map(CodingPathConverter.init).map(\.stringValue).joined(separator: ".")
            self.data.filter({$0.name.hasPrefix(prefix)}).forEach(self.append(_:))
        }
    }

    // MARK: Check
    func checkCanDecodeValue() throws {
        guard !self.isAtEnd else {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Unexpected end of data")
        }
    }
}

// MARK: UnkeyedDecodingContainer
extension URLComponentsDecoderUnkeyedContainer: UnkeyedDecodingContainer {
    func decodeNil() throws -> Bool {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }
        
        let nestedContainer = self.nestedContainers[self.currentIndex]
        
        switch nestedContainer {
        case let singleValueContainer as URLComponentsDecoderSingleValueContainer:
            return singleValueContainer.decodeNil()
        case is URLComponentsDecoderUnkeyedContainer,
             is URLComponentsDecoderKeyedContainer<AnyCodingKey>:
            return false
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Cannot decode nil for index: \(self.currentIndex)")
            throw DecodingError.typeMismatch(Any?.self, context)
        }
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }
        
        let container = self.nestedContainers[self.currentIndex]
        let decoder = URLComponentsDecoder()
        let value = try decoder.decode(T.self, from: container.data)

        return value
    }
    
    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue()
        defer { self.currentIndex += 1 }
        
        let container = self.nestedContainers[self.currentIndex] as! URLComponentsDecoderUnkeyedContainer
        
        return container
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try self.checkCanDecodeValue()
        defer { self.currentIndex += 1 }

        let container = self.nestedContainers[self.currentIndex] as! URLComponentsDecoderKeyedContainer<NestedKey>
        
        return KeyedDecodingContainer(container)

    }

    func superDecoder() throws -> Decoder {
        _URLComponentsDecoder.init(data: self.data)
    }
}

extension URLComponentsDecoderUnkeyedContainer: URLComponentsDecodingContainer {}
