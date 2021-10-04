import Foundation
import Combine

public final class LegacyDetailsModel {
    
    @Published public var detailsData: DetailsDataProtocol
    
    public required init(detailsData: DetailsData) {
        self.detailsData = detailsData
    }
    
}

//MARK: - LegacyDetailsModelProtocol

public extension LegacyDetailsModel {
    
    var changeInformationPublisher: AnyPublisher<DetailsDataProtocol, Never> {
        $detailsData.eraseToAnyPublisher()
    }
    
}
