import Foundation
import UIKit

@MainActor
protocol RelationValueCoordinatorAssemblyProtocol: AnyObject {
    func make() -> RelationValueCoordinatorProtocol
}
