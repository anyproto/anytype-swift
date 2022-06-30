//
//  AccountStatusTests.swift
//  AnytypeTests
//
//  Created by Konstantin Mordan on 29.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import XCTest
@testable import Anytype
@testable import ProtobufMessages

class AccountStatusTests: XCTestCase {


    func test_accountStatusAsModel_retursActive_ifStatusIsActive() throws {
        // given
        let accountStatusMock = Anytype_Model_Account.Status(statusType: .active, deletionDate: 0)
        
        // when
        let statusAsModel = accountStatusMock.asModel
        
        // then
        XCTAssertNotNil(statusAsModel)
        XCTAssertTrue(statusAsModel == .active)
    }
    
    func test_accountStatusAsModel_retursDeleted_ifStatusIsDeleted() throws {
        // given
        let accountStatusMock = Anytype_Model_Account.Status(statusType: .deleted, deletionDate: 0)
        
        // when
        let statusAsModel = accountStatusMock.asModel
        
        // then
        XCTAssertNotNil(statusAsModel)
        XCTAssertTrue(statusAsModel == .deleted)
    }
    
    func test_accountStatusAsModel_retursDeleted_ifStatusIsStartedDeletion() throws {
        // given
        let accountStatusMock = Anytype_Model_Account.Status(statusType: .startedDeletion, deletionDate: 0)
        
        // when
        let statusAsModel = accountStatusMock.asModel
        
        // then
        XCTAssertNotNil(statusAsModel)
        XCTAssertTrue(statusAsModel == .deleted)
    }
    
    func test_accountStatusAsModel_retursNil_ifStatusIsUnrecognized() throws {
        // given
        let accountStatusMock = Anytype_Model_Account.Status(statusType: .UNRECOGNIZED(1), deletionDate: 0)
        
        // when
        let statusAsModel = accountStatusMock.asModel
        
        // then
        XCTAssertNil(statusAsModel)
    }
    
    func test_accountStatusAsModel_retursPendingDeletion_ifStatusIsPendingDeletion() throws {
        // given
        let deletionDate = Date.tomorrow
        let deletionTime = Int64(deletionDate.timeIntervalSince1970)
        
        let accountStatusMock = Anytype_Model_Account.Status(statusType: .pendingDeletion, deletionDate: deletionTime)
        
        // when
        let statusAsModel = accountStatusMock.asModel
        
        // then
        XCTAssertNotNil(statusAsModel)
        XCTAssertTrue(
            statusAsModel == .pendingDeletion(
                deadline: Date(timeIntervalSince1970: TimeInterval(deletionTime))
            )
        )
    }
    
    func test_accountStatusAsModel_retursDeleted_ifStatusIsPendingDeletionOneHourBefore() throws {
        // given
        let deletionDate = Calendar.current.date(byAdding: .hour, value: -1, to: Date())!
        let deletionTime = Int64(deletionDate.timeIntervalSince1970)
        
        let accountStatusMock = Anytype_Model_Account.Status(statusType: .pendingDeletion, deletionDate: deletionTime)
        
        // when
        let statusAsModel = accountStatusMock.asModel
        
        // then
        XCTAssertNotNil(statusAsModel)
        XCTAssertTrue(statusAsModel == .deleted)
    }

}
