import Foundation


final class URLComponentsEncoderKeyedContainer<Key> where Key: CodingKey {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    private var storage: [AnyCodingKey: URLComponentsEncodingContainer] = [:]
    
    func nestedCodingPath(forKey key: CodingKey) -> [CodingKey] {
        self.codingPath + [key]
    }
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    private func nestedSingleValueContainer(forKey key: Key) -> SingleValueEncodingContainer {
        let container = URLComponentsEncoderSingleValueContainer(codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        self.storage[AnyCodingKey(key)] = container
        return container
    }
}

extension URLComponentsEncoderKeyedContainer: KeyedEncodingContainerProtocol {
    func encodeNil(forKey key: Key) throws {
        var container = self.nestedSingleValueContainer(forKey: key)
        try container.encodeNil()
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        var container = self.nestedSingleValueContainer(forKey: key)
        try container.encode(value)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = URLComponentsEncoderUnkeyedContainer(codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        self.storage[AnyCodingKey(key)] = container

        return container
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = URLComponentsEncoderKeyedContainer<NestedKey>(codingPath: self.nestedCodingPath(forKey: key), userInfo: self.userInfo)
        self.storage[AnyCodingKey(key)] = container

        return KeyedEncodingContainer(container)
    }

    func superEncoder() -> Encoder {
        // TODO: Add implementation
        fatalError("Unimplemented")
    }

    func superEncoder(forKey key: Key) -> Encoder {
        // TODO: Add implementation
        fatalError("Unimplemented")
    }
}

extension URLComponentsEncoderKeyedContainer: URLComponentsEncodingContainer {
    var data: [URLQueryItem] {
        var result: [URLQueryItem] = .init()
        for (_, container) in self.storage {
            result.append(contentsOf: container.data)
        }
        return result
    }
}
