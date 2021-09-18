import Foundation
import Combine
import os
import BlocksModels

class DetailsActiveModel {
    
    @Published private(set) var currentDetails: DetailsDataProtocol?
    private(set) var wholeDetailsPublisher: AnyPublisher<DetailsDataProtocol, Never> = .empty()

    private var currentDetailsSubscription: AnyCancellable?
    
    func configured(publisher: AnyPublisher<DetailsDataProtocol, Never>) {
        wholeDetailsPublisher = publisher
        currentDetailsSubscription = publisher.sink { [weak self] (value) in
            self?.currentDetails = value
        }
    }
    
}
