import XCTest
import Services
@testable import Anytype

class TypeFieldsMoveHandlerMoveBetweenSectionTests: XCTestCase {
    var moveHandler: TypeFieldsMoveHandler!
    var mockDocument: MockBaseDocument!
    var mockRelationsService: MockRelationsService!

    override func setUp() {
        super.setUp()
        let mockRelationsService = MockRelationsService()
        Container.shared.relationsService.register { mockRelationsService }
        self.mockRelationsService = mockRelationsService
        mockDocument = MockBaseDocument()
        moveHandler = TypeFieldsMoveHandler()
    }
    
    func testMoveBetweenSectionsFromHeaderStartToFieldsStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: 1, // First relation after header
            to: 5,  // First position in fields section
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h1", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
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
            from: 1,
            to: 6,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["f1", "h1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
            ["h2", "h3"]
        )
    }

    func testMoveBetweenSectionsFromHeaderMiddleToFieldsStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: 2,
            to: 5,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h2", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
            ["h1", "h3"]
        )
    }

    func testMoveBetweenSectionsFromHeaderEndToFieldsStart() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: 3,
            to: 5,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h3", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
            ["h1", "h2"]
        )
    }

    func testMoveBetweenSectionsFromFieldsMiddleToHeaderEnd() async throws {
        let relationRows = createBothSectionsRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3"],
            recommendedRelations: ["f1", "f2", "f3"]
        )
        
        try await moveHandler.onMove(
            from: 6,
            to: 3,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["f1", "f3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
            ["h1", "h2", "h3", "f2"]
        )
    }

    // Helper method for between sections tests
    private func createBothSectionsRows() -> [TypeFieldsRow] {
        let headerSection = TypeFieldsSectionRow.header
        let fieldsSection = TypeFieldsSectionRow.fieldsMenu
        return [
            .header(.header),
            .relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h1"), canDrag: true)),
            .relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h2"), canDrag: true)),
            .relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h3"), canDrag: true)),
            .header(.fieldsMenu),
            .relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f1"), canDrag: true)),
            .relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f2"), canDrag: true)),
            .relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f3"), canDrag: true))
        ]
    }
}
