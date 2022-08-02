import Foundation
import UIKit

protocol TemplatesCoordinatorAssemblyProtocol: AnyObject {
    func make(viewController: UIViewController) -> TemplatesCoordinator
}
