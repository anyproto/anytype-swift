//
//  SmartBlockType.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import ProtobufMessages

public enum SmartBlockType: Hashable, Codable {
    case accountOld // = 0
    case breadcrumbs // = 1
    case page // = 16
    case profilePage // = 17
    case home // = 32
    case archive // = 48
    case database // = 64

    /// only have dataview simpleblock
    case set // = 65

    /// have relations list
    case stobjectType // = 96
    case file // = 256
    case template // = 288
    case bundledTemplate // = 289
    case marketplaceType // = 272
    case marketplaceRelation // = 273
    case marketplaceTemplate // = 274
    case bundledRelation // = 512
    case indexedRelation // = 513
    case bundledObjectType // = 514
    case anytypeProfile // = 515
    case date // = 516

    /// deprecated thread-based workspace
    case workspaceOld // = 517
    case workspace // = 518
    case UNRECOGNIZED(Int)
}

extension SmartBlockType {
    
    init(smartBlockType: Anytype_Model_SmartBlockType) {
        switch smartBlockType {
        case .accountOld:
            self = .accountOld
        case .breadcrumbs:
            self = .breadcrumbs
        case .page:
            self = .page
        case .profilePage:
            self = .profilePage
        case .home:
            self = .home
        case .archive:
            self = .archive
        case .database:
            self = .database
        case .set:
            self = .set
        case .stobjectType:
            self = .stobjectType
        case .file:
            self = .file
        case .template:
            self = .template
        case .bundledTemplate:
            self = .bundledTemplate
        case .marketplaceType:
            self = .marketplaceType
        case .marketplaceRelation:
            self = .marketplaceRelation
        case .marketplaceTemplate:
            self = .marketplaceTemplate
        case .bundledRelation:
            self = .bundledRelation
        case .indexedRelation:
            self = .indexedRelation
        case .bundledObjectType:
            self = .bundledObjectType
        case .anytypeProfile:
            self = .anytypeProfile
        case .date:
            self = .date
        case .workspaceOld:
            self = .workspaceOld
        case .workspace:
            self = .workspace
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
    
}
