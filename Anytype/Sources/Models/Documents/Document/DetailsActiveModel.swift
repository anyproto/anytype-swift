import Foundation
import Combine
import os
import BlocksModels

class DetailsActiveModel {
    
    @Published private(set) var currentDetails: DetailsData?
    private(set) var wholeDetailsPublisher: AnyPublisher<DetailsData, Never> = .empty()

    private var currentDetailsSubscription: AnyCancellable?
    
    func configured(publisher: AnyPublisher<DetailsData, Never>) {
        wholeDetailsPublisher = publisher
        currentDetailsSubscription = publisher.sink { [weak self] (value) in
            self?.currentDetails = value
        }
    }
    
}
