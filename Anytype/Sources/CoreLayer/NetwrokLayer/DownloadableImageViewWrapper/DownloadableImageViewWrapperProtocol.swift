import Foundation
import UIKit

protocol DownloadableImageViewWrapperProtocol {
    
    @discardableResult
    func imageGuideline(_ imageGuideline: ImageGuideline) -> DownloadableImageViewWrapperProtocol
    
    @discardableResult
    func scalingType(_ scalingType: KFScalingType?) -> DownloadableImageViewWrapperProtocol
    
    @discardableResult
    func animatedTransition( _ animatedTransition: Bool) -> DownloadableImageViewWrapperProtocol
    
    @discardableResult
    func placeholderNeeded( _ placeholderNeeded: Bool) -> DownloadableImageViewWrapperProtocol
    
    func setImage(id: String)
    func setImage(url: URL)
    func setImage(_ image: UIImage?)
    
}
