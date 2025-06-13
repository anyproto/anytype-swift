import XCTest
import Services
@testable import Anytype

class TypePropertiesMoveHandlerMoveBetweenSectionTests: XCTestCase {
    var moveHandler: TypePropertiesMoveHandler!
    var mockDocument: MockBaseDocument!
    var mockPropertiesService: MockPropertiesService!

    override func setUp() {
        super.setUp()
        let mockPropertiesService = MockPropertiesService()
        Container.shared.propertiesService.register { mockPropertiesService }
        self.mockPropertiesService = mockPropertiesService
        mockDocument = MockBaseDocument()
        moveHandler = TypePropertiesMoveHandler()
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
            mockPropertiesService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h1", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
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
            mockPropertiesService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["f1", "h1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
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
            mockPropertiesService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h2", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
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
            mockPropertiesService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["h3", "f1", "f2", "f3"]
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
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
            mockPropertiesService.lastUpdateTypeRelations?.recommendedRelations.map(\.id),
            ["f1", "f3"]
        )
        XCTAssertEqual(
            mockPropertiesService.lastUpdateTypeRelations?.recommendedFeaturedRelations.map(\.id),
            ["h1", "h2", "h3", "f2"]
        )
    }

    // Helper method for between sections tests
    private func createBothSectionsRows() -> [TypePropertiesRow] {
        let headerSection = TypePropertiesSectionRow.header
        let fieldsSection = TypePropertiesSectionRow.fieldsMenu
        return [
            .header(.header),
            .relation(TypePropertiesRelationRow(section: headerSection, relation: .mock(id: "h1"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: headerSection, relation: .mock(id: "h2"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: headerSection, relation: .mock(id: "h3"), canDrag: true)),
            .header(.fieldsMenu),
            .relation(TypePropertiesRelationRow(section: fieldsSection, relation: .mock(id: "f1"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: fieldsSection, relation: .mock(id: "f2"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: fieldsSection, relation: .mock(id: "f3"), canDrag: true))
        ]
    }
}
