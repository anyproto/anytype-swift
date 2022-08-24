import Foundation

protocol SystemURLServiceProtocol: AnyObject {
    func buildPhoneUrl(phone: String) -> URL?
    func buildEmailUrl(to: String) -> URL?
}
