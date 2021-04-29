import Foundation

protocol URLComponentsDecodingContainer: AnyObject {
    var data: [URLQueryItem] { get set }
}
