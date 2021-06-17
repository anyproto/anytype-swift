import Foundation


final class URLComponentsDecoderKeyedContainer<Key> where Key: CodingKey {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var data: [URLQueryItem] = []
    
    var nestedContainers: [String: URLComponentsDecodingContainer] = [:]
    
    init(data: [URLQueryItem], codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.process()
    }

    // MARK: Append
    private func append(_ item: URLQueryItem) {
        let name = item.name
        let nestedCodingPath: [CodingKey] = self.codingPath + [Key(stringValue: name)!]
        self.nestedContainers[name] = URLComponentsDecoderSingleValueContainer(data: self.data, codingPath: nestedCodingPath, userInfo: self.userInfo)
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
    func checkCanDecodeValue(forKey key: Key) throws {
        guard self.contains(key) else {
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "Key not found: \(key)")
            throw DecodingError.keyNotFound(key, context)
        }
    }
}

extension URLComponentsDecoderKeyedContainer: KeyedDecodingContainerProtocol, URLComponentsDecodingContainer {
    var allKeys: [Key] {
        self.nestedContainers.keys.map({Key.init(stringValue: $0)!})
    }
    
    func contains(_ key: Key) -> Bool {
        self.nestedContainers.keys.contains(key.stringValue)
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        try self.checkCanDecodeValue(forKey: key)
        
        let nestedContainer = self.nestedContainers[key.stringValue]
        switch nestedContainer {
        case let singleValueContainer as URLComponentsDecoderSingleValueContainer:
            return singleValueContainer.decodeNil()
        case is URLComponentsDecoderUnkeyedContainer,
             is URLComponentsDecoderKeyedContainer<AnyCodingKey>:
            return false
        default:
            let context = DecodingError.Context(codingPath: self.codingPath, debugDescription: "cannot decode nil for key: \(key)")
            throw DecodingError.typeMismatch(Any?.self, context)
        }
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try self.checkCanDecodeValue(forKey: key)
        
        let container = self.nestedContainers[key.stringValue]!

        let decoder = URLComponentsDecoder()
        decoder.codingPath = self.codingPath + [key]
        let value = try decoder.decode(T.self, from: container.data)
        
        return value
    }
 
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try checkCanDecodeValue(forKey: key)
        
        guard let unkeyedContainer = self.nestedContainers[key.stringValue] as? URLComponentsDecoderUnkeyedContainer else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "cannot decode nested container for key: \(key)")
        }
        
        return unkeyedContainer
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try self.checkCanDecodeValue(forKey: key)
        
        guard let keyedContainer = self.nestedContainers[key.stringValue] as? URLComponentsDecoderKeyedContainer<NestedKey> else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "cannot decode nested container for key: \(key)")
        }
        
        return KeyedDecodingContainer(keyedContainer)
    }
    
    func superDecoder() throws -> Decoder {
        _URLComponentsDecoder(data: self.data)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        let decoder = _URLComponentsDecoder(data: self.data)
        decoder.codingPath = [key]
        return decoder
    }
}
