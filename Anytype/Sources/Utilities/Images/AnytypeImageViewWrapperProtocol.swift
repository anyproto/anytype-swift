import Foundation
import UIKit

protocol AnytypeImageViewWrapperProtocol {
    
    @discardableResult
    func imageGuideline(_ imageGuideline: ImageGuideline) -> AnytypeImageViewWrapperProtocol
    
    @discardableResult
    func scalingType(_ scalingType: KFScalingType) -> AnytypeImageViewWrapperProtocol
    
    @discardableResult
    func animatedTransition( _ animatedTransition: Bool) -> AnytypeImageViewWrapperProtocol
    
    @discardableResult
    func placeholderNeeded( _ placeholderNeeded: Bool) -> AnytypeImageViewWrapperProtocol
    
    func setImage(id: String)
    func setImage(url: URL)
    func setImage(_ image: UIImage?)
    
}
