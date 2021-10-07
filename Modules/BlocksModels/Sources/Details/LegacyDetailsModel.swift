import Foundation
import Combine

public final class LegacyDetailsModel {
    
    public var detailsData: DetailsDataProtocol
    
    public required init(detailsData: DetailsData) {
        self.detailsData = detailsData
    }
    
}
