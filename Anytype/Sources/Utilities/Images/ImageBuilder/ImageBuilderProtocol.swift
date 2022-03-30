import Foundation
import UIKit

protocol ImageBuilderProtocol {
    
    func setImageColor(_ imageColor: UIColor) -> ImageBuilderProtocol
    func setText(_ text: String) -> ImageBuilderProtocol
    func setTextColor(_ textColor: UIColor) -> ImageBuilderProtocol
    func setFont(_ font: UIFont) -> ImageBuilderProtocol
    
    func build() -> UIImage
    
}
