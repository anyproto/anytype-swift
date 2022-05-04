import Foundation
import SwiftUI

protocol RelationOptionsSearchModuleBuilderProtocol {
    
    func buildModule(
        excludedOptionIds: [String],
        onSelect: @escaping (_ ids: [String]) -> Void,
        onCreate: @escaping (_ title: String) -> Void
    ) -> NewSearchView
    
}
