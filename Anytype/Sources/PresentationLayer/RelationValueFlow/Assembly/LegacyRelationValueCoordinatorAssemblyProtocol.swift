import Foundation
import UIKit

@MainActor
protocol LegacyRelationValueCoordinatorAssemblyProtocol: AnyObject {
    func make() -> LegacyRelationValueCoordinatorProtocol
}
