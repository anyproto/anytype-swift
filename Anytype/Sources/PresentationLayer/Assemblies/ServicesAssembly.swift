import Foundation
import UIKit

protocol ServicesAssemblyProtocol: AnyObject {
    var search: SearchServiceProtocol { get }
}

final class ServicesAssembly: ServicesAssemblyProtocol {
    
    // MARK: - ServicesAssemblyProtocol
    
    lazy var search: SearchServiceProtocol = {
        return SearchService()
    }()
}
