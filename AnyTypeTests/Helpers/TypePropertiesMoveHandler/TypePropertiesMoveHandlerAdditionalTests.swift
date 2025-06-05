import XCTest
import Services
@testable import Anytype

class TypePropertiesMoveHandlerAdditionalTests: XCTestCase {
    var moveHandler: TypePropertiesMoveHandler!
    var mockDocument: MockBaseDocument!
    var mockRelationsService: MockRelationsService!
    
    override func setUp() {
        super.setUp()
        let mockRelationsService = MockRelationsService()
        Container.shared.relationsService.register { mockRelationsService }
        let mockPropertyDetailsStorage = MockPropertyDetailsStorage()
        Container.shared.propertyDetailsStorage.register { mockPropertyDetailsStorage }
        self.mockRelationsService = mockRelationsService
        mockDocument = MockBaseDocument()
        moveHandler = TypePropertiesMoveHandler()
    }
    
    // MARK: - Empty Section Tests
    
    func testMoveToEmptyHeaderSection() async throws {
        let relationRows: [TypePropertiesRow] = [
            .header(.header),
            .emptyRow(.header),
            .header(.fieldsMenu),
            .relation(TypePropertiesRelationRow(section: .fieldsMenu, relation: .mock(id: "f1"), canDrag: true))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: [],
            recommendedRelations: ["f1"]
        )
        
        try await moveHandler.onMove(
            from: 3,
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            []
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
            ["f1"]
        )
    }
    
    func testMoveToEmptyFieldsSection() async throws {
        let relationRows: [TypePropertiesRow] = [
            .header(.header),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "h1"), canDrag: true)),
            .header(.fieldsMenu),
            .emptyRow(.fieldsMenu)
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1"],
            recommendedRelations: []
        )
        
        try await moveHandler.onMove(
            from: 1,
            to: 3,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h1"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
            []
        )
    }
    
    // MARK: - Edge Cases with Document Details
    
    func testMoveWithMissingRecommendedRelations() async throws {
        let relationRows: [TypePropertiesRow] = [
            .header(.fieldsMenu),
            .relation(TypePropertiesRelationRow(section: .fieldsMenu, relation: .mock(id: "f1"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: .fieldsMenu, relation: .mock(id: "f2"), canDrag: true))
        ]
        
        let details = ObjectDetails.mock(recommendedRelations: [])
        mockDocument.mockDetails = details
        
        try await moveHandler.onMove(
            from: 1,
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertNil(mockRelationsService.lastUpdateRecommendedRelations)
    }
    
    func testMoveWithInvalidRelationId() async throws {
        let relationRows: [TypePropertiesRow] = [
            .header(.header),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "invalid_id"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "h2"), canDrag: true))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h2"]
        )
        
        try await moveHandler.onMove(
            from: 1,
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertNil(mockRelationsService.lastUpdateRecommendedFeaturedRelations)
    }
    
    // MARK: - Concurrent Updates Tests
    
    func testConcurrentMoves() async throws {
        let relationRows: [TypePropertiesRow] = [
            .header(.header),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "h1"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "h2"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "h3"), canDrag: true))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"]
        )
        
        // Perform multiple moves concurrently
        async let move1: () = moveHandler.onMove(from: 1, to: 2, relationRows: relationRows, document: mockDocument)
        async let move2: () = moveHandler.onMove(from: 2, to: 3, relationRows: relationRows, document: mockDocument)
        
        try await (move1, move2)
        
        // The last update should be applied
        XCTAssertNotNil(mockRelationsService.lastUpdateRecommendedFeaturedRelations)
    }
    
    // MARK: - Header Navigation Tests
    
    func testMoveToHeaderWithNoNextItem() async throws {
        let relationRows: [TypePropertiesRow] = [
            .header(.header),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "h1"), canDrag: true)),
            .header(.fieldsMenu)
        ]
        
        do {
            try await moveHandler.onMove(
                from: 1,
                to: 2,
                relationRows: relationRows,
                document: mockDocument
            )
            XCTFail("Expected emptySection error")
        } catch let error as TypePropertiesMoveError {
            XCTAssertEqual(error, .emptySection)
        }
    }
    
    func testMoveToHeaderWithNoPreviousItem() async throws {
        let relationRows: [TypePropertiesRow] = [
            .header(.header),
            .header(.fieldsMenu),
            .relation(TypePropertiesRelationRow(section: .fieldsMenu, relation: .mock(id: "f1"), canDrag: true))
        ]
        
        do {
            try await moveHandler.onMove(
                from: 2,
                to: 0,
                relationRows: relationRows,
                document: mockDocument
            )
            XCTFail("Expected emptySection error")
        } catch let error as TypePropertiesMoveError {
            XCTAssertEqual(error, .emptySection)
        }
    }
}
