import Foundation
import UIKit

protocol ImageBuilderProtocol {
    
    func setImageColor(_ imageColor: UIColor) -> any ImageBuilderProtocol
    func setText(_ text: String) -> any ImageBuilderProtocol
    func setTextColor(_ textColor: UIColor) -> any ImageBuilderProtocol
    func setFont(_ font: UIFont) -> any ImageBuilderProtocol
    
    @MainActor
    func build() -> UIImage
    
}
