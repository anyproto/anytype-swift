import Foundation

protocol URLComponentsDecodingContainer: class {
    var data: [URLQueryItem] { get set }
}
