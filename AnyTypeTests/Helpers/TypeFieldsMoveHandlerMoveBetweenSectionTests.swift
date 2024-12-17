import XCTest
import Services
@testable import Anytype

class TypeFieldsMoveHandlerMoveBetweenSectionTests: XCTestCase {
    var moveHandler: TypeFieldsMoveHandler!
    var mockDocument: MockBaseDocument!
    var mockRelationsService: MockRelationsService!

    override func setUp() {
        super.setUp()
        mockRelationsService = MockRelationsService()
        mockDocument = MockBaseDocument()
        moveHandler = TypeFieldsMoveHandler()
        moveHandler.relationsService = mockRelationsService
    }
    
    // Do not work with current move API
    func disabled_testMoveBetweenSectionsFromHeaderStartToFieldsStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 1), // First relation after header
            to: 6,  // First position in fields section
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["h1", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["h2", "h3"]
        )
    }

    func testMoveBetweenSectionsFromHeaderStartToFieldsMiddle() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 1),
            to: 7,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["f1", "h1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["h2", "h3"]
        )
    }

    func testMoveBetweenSectionsFromHeaderStartToFieldsEnd() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 1),
            to: 9,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["f1", "f2", "f3", "h1"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["h2", "h3"]
        )
    }

    // Do not work with current move API
    func disabled_testMoveBetweenSectionsFromHeaderMiddleToFieldsStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 2),
            to: 6,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["h2", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["h1", "h3"]
        )
    }

    // Do not work with current move API
    func disabled_testMoveBetweenSectionsFromHeaderEndToFieldsStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 3),
            to: 6,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["h3", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["h1", "h2"]
        )
    }

    // Tests for moving from Fields section to Header section
    func testMoveBetweenSectionsFromFieldsStartToHeaderStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 6),
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["f1", "h1", "h2", "h3"]
        )
    }

    func testMoveBetweenSectionsFromFieldsStartToHeaderMiddle() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 6),
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["h1", "f1", "h2", "h3"]
        )
    }

    // Do not work with current move API
    func disabled_testMoveBetweenSectionsFromFieldsMiddleToHeaderEnd() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 7),
            to: 4,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["f1", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["h1", "h2", "h3", "f2"]
        )
    }

    func testMoveBetweenSectionsFromFieldsEndToHeaderStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 8),
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["f1", "f2"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            ["f3", "h1", "h2", "h3"]
        )
    }

    // Helper method for between sections tests
    private func createBothSectionsRows() -> [TypeFieldsRow] {
        let headerSection = TypeFieldsSectionRow.header
        let fieldsSection = TypeFieldsSectionRow.fieldsMenu
        return [
            TypeFieldsRow.header(.header),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h1"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h2"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h3"))),
            TypeFieldsRow.header(.fieldsMenu),
            TypeFieldsRow.emptyRow(.fieldsMenu),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f1"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f2"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f3")))
        ]
    }
}
