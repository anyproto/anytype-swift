import Foundation
import UIKit

@MainActor
protocol DownloadableImageViewWrapperProtocol {
    
    @discardableResult
    func imageGuideline(_ imageGuideline: ImageGuideline) -> any DownloadableImageViewWrapperProtocol
    
    @discardableResult
    func scalingType(_ scalingType: KFScalingType?) -> any DownloadableImageViewWrapperProtocol
    
    @discardableResult
    func animatedTransition( _ animatedTransition: Bool) -> any DownloadableImageViewWrapperProtocol
    
    @discardableResult
    func placeholderNeeded( _ placeholderNeeded: Bool) -> any DownloadableImageViewWrapperProtocol
    
    func setImage(id: String)
    func setImage(url: URL)
    func setImage(_ image: UIImage?)
    
}
