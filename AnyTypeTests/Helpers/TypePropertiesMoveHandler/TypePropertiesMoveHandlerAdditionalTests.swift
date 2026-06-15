import XCTest
import Services
@testable import Anytype

class TypePropertiesMoveHandlerAdditionalTests: XCTestCase {
    var moveHandler: TypePropertiesMoveHandler!
    var mockDocument: MockBaseDocument!
    var mockPropertiesService: MockPropertiesService!
    var mockPropertyDetailsStorage: MockPropertyDetailsStorage!

    override func setUp() {
        super.setUp()
        let mockPropertiesService = MockPropertiesService()
        Container.shared.propertiesService.register { mockPropertiesService }
        let mockPropertyDetailsStorage = MockPropertyDetailsStorage()
        Container.shared.propertyDetailsStorage.register { mockPropertyDetailsStorage }
        self.mockPropertiesService = mockPropertiesService
        self.mockPropertyDetailsStorage = mockPropertyDetailsStorage
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
            mockPropertiesService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            []
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
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
            mockPropertiesService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h1"]
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
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
        
        XCTAssertNil(mockPropertiesService.lastUpdateRecommendedRelations)
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
        
        XCTAssertNil(mockPropertiesService.lastUpdateRecommendedFeaturedRelations)
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
        XCTAssertNotNil(mockPropertiesService.lastUpdateRecommendedFeaturedRelations)
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

    // MARK: - IOS-6181 regression

    // Reproduces Sentry IOS-8H5: middleware returns IDs in `recommendedFeaturedRelations`
    // for which `PropertyDetailsStorage` has no entry, so the parallel details array is shorter.
    // Pre-fix, the handler looked up `toIndex` in the IDs array and applied `toIndex + 1` to
    // the (shorter) details array, trapping in `Array._checkIndex`.
    func testMoveFromFieldsMenuToHeaderWithMissingFeaturedDetails() async throws {
        // "h1" exists in the IDs array but the storage drops it (no PropertyDetails).
        // So recommendedFeaturedRelationsDetails resolves to only [h2] — length 1.
        mockPropertyDetailsStorage.missingIds = ["h1"]

        let relationRows: [TypePropertiesRow] = [
            .header(.header),
            .relation(TypePropertiesRelationRow(section: .header, relation: .mock(id: "h2"), canDrag: true)),
            .header(.fieldsMenu),
            .relation(TypePropertiesRelationRow(section: .fieldsMenu, relation: .mock(id: "f1"), canDrag: true))
        ]

        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2"],
            recommendedRelations: ["f1"]
        )

        // Drag f1 onto h2 row in the header section. Pre-fix this trapped at
        // `newFeaturedRelations.insert(fromRelation, at: toIndex + 1)`.
        try await moveHandler.onMove(
            from: 3,
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )

        // f1 lands after h2 in the featured array; the orphaned h1 ID is dropped from the
        // payload (it had no details, so it was never visible to the user anyway).
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeProperties?.recommendedFeaturedProperties.map(\.id),
            ["h2", "f1"]
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeProperties?.recommendedProperties.map(\.id),
            []
        )
    }
}
