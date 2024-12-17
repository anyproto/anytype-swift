import XCTest
import Services
@testable import Anytype

class TypeFieldsMoveHandlerMoveWithinSectionTests: XCTestCase {
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

    // Header Section Movement Tests
    func testMoveWithinHeaderSectionFromStartToMiddle() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 1), // First relation after header
            to: 3,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateFeaturedRelations,
            ["h2", "h1", "h3", "h4"]
        )
    }

    func testMoveWithinHeaderSectionFromStartToEnd() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 1),
            to: 5,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateFeaturedRelations,
            ["h2", "h3", "h4", "h1"]
        )
    }

    func testMoveWithinHeaderSectionFromMiddleToStart() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 2),
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateFeaturedRelations,
            ["h2", "h1", "h3", "h4"]
        )
    }

    func testMoveWithinHeaderSectionFromMiddleToEnd() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 2),
            to: 5,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateFeaturedRelations,
            ["h1", "h3", "h4", "h2"]
        )
    }

    func testMoveWithinHeaderSectionFromEndToStart() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 4),
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateFeaturedRelations,
            ["h4", "h1", "h2", "h3"]
        )
    }

    func testMoveWithinHeaderSectionFromEndToMiddle() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 4),
            to: 3,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateFeaturedRelations,
            ["h1", "h2", "h4", "h3"]
        )
    }

    // Fields Section Movement Tests
    func testMoveWithinFieldsSectionFromStartToMiddle() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 6), // First relation after fields menu header
            to: 8,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateRecommendedRelations?.relationIds,
            ["f2", "f1", "f3", "f4"]
        )
    }

    func testMoveWithinFieldsSectionFromStartToEnd() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 6),
            to: 10,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateRecommendedRelations?.relationIds,
            ["f2", "f3", "f4", "f1"]
        )
    }

    func testMoveWithinFieldsSectionFromMiddleToStart() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 7),
            to: 6,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateRecommendedRelations?.relationIds,
            ["f2", "f1", "f3", "f4"]
        )
    }

    func testMoveWithinFieldsSectionFromMiddleToEnd() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 7),
            to: 10,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateRecommendedRelations?.relationIds,
            ["f1", "f3", "f4", "f2"]
        )
    }

    func testMoveWithinFieldsSectionFromEndToStart() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 9),
            to: 6,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateRecommendedRelations?.relationIds,
            ["f4", "f1", "f2", "f3"]
        )
    }

    func testMoveWithinFieldsSectionFromEndToMiddle() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: IndexSet(integer: 9),
            to: 8,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockRelationsService.lastUpdateRecommendedRelations?.relationIds,
            ["f1", "f2", "f4", "f3"]
        )
    }

    // Helper methods
    private func createHeaderSectionRows() -> [TypeFieldsRow] {
        let headerSection = TypeFieldsSectionRow.header
        return [
            TypeFieldsRow.header(.header),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h1"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h2"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h3"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h4"))),
            TypeFieldsRow.header(.fieldsMenu)
        ]
    }

    private func createFieldsSectionRows() -> [TypeFieldsRow] {
        let headerSection = TypeFieldsSectionRow.header
        let fieldsSection = TypeFieldsSectionRow.fieldsMenu
        return [
            TypeFieldsRow.header(.header),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h1"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h2"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h3"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: .mock(id: "h4"))),
            TypeFieldsRow.header(.fieldsMenu),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f1"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f2"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f3"))),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: .mock(id: "f4")))
        ]
    }
}
