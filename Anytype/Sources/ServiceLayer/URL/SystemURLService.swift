import Foundation

class SystemURLService: SystemURLServiceProtocol {
    
    func buildPhoneUrl(phone: String) -> URL? {
        URL(string: "tel:\(phone)")
    }
    
    func buildEmailUrl(to: String) -> URL? {
        URL(string: "mailto:\(to)")
    }
}
