import Foundation
import Combine

class URLComponentsEncoder {
    public init() {}
    
    public var userInfo: [CodingUserInfoKey : Any] = [:]
}

extension URLComponentsEncoder: TopLevelEncoder {
    public func encode<T>(_ value: T) throws -> [URLQueryItem] where T : Encodable {
        let encoder = _URLComponentsEncoder()
        encoder.userInfo = self.userInfo
        try value.encode(to: encoder)
        return encoder.data
    }
}

protocol URLComponentsEncodingContainer: AnyObject {
    // We are encoding, so, our result is URLComponents or, specifically, [URRQueryItem]
    var data: [URLQueryItem] { get }
}

final class _URLComponentsEncoder: Encoder, URLComponentsEncodingContainer {    
    var codingPath: [CodingKey] = []
    
    var userInfo: [CodingUserInfoKey : Any] = [:]
    
    var data: [URLQueryItem] {
        self.container?.data ?? []
    }
    
    fileprivate var container: URLComponentsEncodingContainer?
    fileprivate func assertCanCreateContainer() {
        precondition(self.container.isNil)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        assertCanCreateContainer()
        
        let container = URLComponentsEncoderKeyedContainer<Key>(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanCreateContainer()
        
        let container = URLComponentsEncoderUnkeyedContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanCreateContainer()
        
        let container = URLComponentsEncoderSingleValueContainer(codingPath: self.codingPath, userInfo: self.userInfo)
        self.container = container
        
        return container
    }
}
