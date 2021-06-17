import Foundation

protocol CodableAndDictionary: Codable {}

extension CodableAndDictionary {
    static func create(dictionary: [String : AnyObject]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try JSONDecoder().decode(Self.self, from: data)
        //self.init(from: JSONDecoder.self)
    }
    
    func dictionary() -> [String : AnyObject]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        guard let result = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return nil
        }
        
        return result as? [String : AnyObject]
    }
}
