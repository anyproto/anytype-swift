import Foundation
import Combine

class URLComponentsDecoder: TopLevelDecoder {
    public init() {}
    internal var codingPath: [CodingKey] = []
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    public func decode<T>(_ type: T.Type, from: [URLQueryItem]) throws -> T where T : Decodable {
        let decoder = _URLComponentsDecoder(data: from)
        decoder.codingPath = self.codingPath
        return try T(from: decoder)
    }
}

final class _URLComponentsDecoder: Decoder {
    var codingPath: [CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    var container: URLComponentsDecodingContainer?
    
    var data: [URLQueryItem] = []
    
    init(data: [URLQueryItem]) {
        self.data = data
    }

    fileprivate func assertCanCreateContainer() {
        precondition(self.container.isNil)
    }

    // MARK: -  Decoder
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        self.assertCanCreateContainer()
        
        let container = URLComponentsDecoderKeyedContainer<Key>(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return KeyedDecodingContainer(container)
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        self.assertCanCreateContainer()
        
        let container = URLComponentsDecoderUnkeyedContainer(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container

        return container
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        self.assertCanCreateContainer()
        
        let container = URLComponentsDecoderSingleValueContainer(data: self.data, codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}
