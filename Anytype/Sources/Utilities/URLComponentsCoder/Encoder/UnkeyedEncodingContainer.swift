import Foundation

final class URLComponentsEncoderUnkeyedContainer {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    private var storage: [URLComponentsEncodingContainer] = []
    
    var nestedCodingPath: [CodingKey] {
        self.codingPath + [AnyCodingKey(intValue: self.count)!]
    }
    
    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    private func nestedSingleValueContainer() -> SingleValueEncodingContainer {
        let container = URLComponentsEncoderSingleValueContainer(codingPath: self.nestedCodingPath, userInfo: self.userInfo)
        return container
    }
}

extension URLComponentsEncoderUnkeyedContainer: UnkeyedEncodingContainer {
    var count: Int {
        self.storage.count
    }
    
    func encodeNil() throws {
        var container = self.nestedSingleValueContainer()
        try container.encodeNil()
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        var container = self.nestedSingleValueContainer()
        try container.encode(value)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = URLComponentsEncoderKeyedContainer<NestedKey>(codingPath: self.nestedCodingPath, userInfo: self.userInfo)
        self.storage.append(container)
        
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = URLComponentsEncoderUnkeyedContainer(codingPath: self.nestedCodingPath, userInfo: self.userInfo)
        self.storage.append(container)
        
        return container
    }
    
    func superEncoder() -> Encoder {
        // TODO: Add implementation
        fatalError("Unimplemented")
    }
}

extension URLComponentsEncoderUnkeyedContainer: URLComponentsEncodingContainer {
    var data: [URLQueryItem] {
        var result: [URLQueryItem] = .init()
        for (_, value) in self.storage.enumerated() {
            result.append(contentsOf: value.data)
        }
        return result
    }
}
