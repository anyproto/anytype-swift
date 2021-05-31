//
//  DetailsModel.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Combine

// TODO: Make one class from DetailsInformationModelProtocol and DetailsModel
final class DetailsModel: ObservableObject {
    
    @Published private var detailsInformation: DetailsProviderProtocol
    
    required init(detailsProvider: DetailsProviderProtocol) {
        self.detailsInformation = detailsProvider
    }
    
}

//MARK: - DetailsModelProtocol

extension DetailsModel: DetailsModelProtocol {
    
    var changeInformationPublisher: AnyPublisher<DetailsProviderProtocol, Never> {
        $detailsInformation.eraseToAnyPublisher()
    }
    
    var detailsProvider: DetailsProviderProtocol {
        get {
            self.detailsInformation
        }
        set {
            /// TODO:
            /// Refactor later.
            ///
            /// Check if parent ids are not equal.
            /// If so, take parent id and set it to new value.
            ///
            
            var newValue = newValue
            if self.detailsInformation.parentId != newValue.parentId {
                newValue.parentId = self.detailsInformation.parentId
            }
            self.detailsInformation = newValue
        }
    }
        
    /// TODO: Add parent to model or extend PageDetails to store parentId.
    var parent: ParentId? {
        get {
            self.detailsInformation.parentId
        }
        set {
            self.detailsInformation.parentId = newValue
        }
    }
    
}
