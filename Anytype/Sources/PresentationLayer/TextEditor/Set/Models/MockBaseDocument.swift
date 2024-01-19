//
//  MockBaseDocument.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 13.09.23.
//  Copyright © 2023 Anytype. All rights reserved.
//

import Services
import Foundation
import Combine

final class MockBaseDocument: BaseDocumentProtocol {
    
    var spaceId: String { "" } 
    
    var infoContainer: Services.InfoContainerProtocol { InfoContainer() }
    
    var objectRestrictions: Services.ObjectRestrictions { ObjectRestrictions() }
    
    var detailsStorage: Services.ObjectDetailsStorage { ObjectDetailsStorage() }
    
    var objectId: Services.BlockId { "" }
    
    var children: [Services.BlockInformation] { [] }
    
    var parsedRelations: ParsedRelations { .empty }
    
    var isLocked: Bool { false }
    
    var relationValuesIsLocked: Bool { false }
    
    var relationsListIsLocked: Bool { false }
    
    var isEmpty: Bool { false }
    
    var isOpened: Bool { true }
    
    var isArchived: Bool { false }
    
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> { .empty() }
    
    var syncPublisher: AnyPublisher<Void, Never> { .empty() }
        
    var details: Services.ObjectDetails? { nil }
    
    var detailsPublisher: AnyPublisher<Services.ObjectDetails, Never> { .empty() }
    
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { .empty() }
    
    var forPreview: Bool { false }
    
    func open() async throws { }
    
    func openForPreview() async throws { }
    
    func close() async throws { }
}
