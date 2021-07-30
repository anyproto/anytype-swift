import Foundation
import Combine

public final class LegacyDetailsModel {
    
    @Published public var detailsData: DetailsData
    
    public required init(detailsData: DetailsData) {
        self.detailsData = detailsData
    }
    
}

//MARK: - LegacyDetailsModelProtocol

public extension LegacyDetailsModel {
    
    var changeInformationPublisher: AnyPublisher<DetailsData, Never> {
        $detailsData.eraseToAnyPublisher()
    }
    
}
