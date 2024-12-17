import XCTest
import Services
@testable import Anytype

class TypeFieldsMoveHandlerTests: XCTestCase {
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

    func testSuccessfulMoveWithinHeaderSection() async throws {
        // Arrange
        let headerSection = TypeFieldsSectionRow.header
        let relation1 = Relation.mock(id: "relation1")
        let relation2 = Relation.mock(id: "relation2")
        let relation3 = Relation.mock(id: "relation3")
        
        let relationRows = [
            TypeFieldsRow.header(.header),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: relation1)),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: relation2)),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: relation3))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["relation1", "relation2", "relation3"]
        )
        
        // Act
        try await moveHandler.onMove(
            from: IndexSet(integer: 1),
            to: 4,
            relationRows: relationRows,
            document: mockDocument
        )
        
        // Assert
        XCTAssertEqual(
            mockRelationsService.lastUpdateFeaturedRelations,
            ["relation2", "relation3", "relation1"]
        )
    }

    func testErrorHandling() async {
        // 1. Non-singular from index
        do {
            try await moveHandler.onMove(
                from: IndexSet(integersIn: 0...1),
                to: 1,
                relationRows: [],
                document: mockDocument
            )
            XCTFail("Expected nonSingularFromIndex error")
        } catch let error as TypeFieldsMoveError {
            XCTAssertEqual(error, .nonSingularFromIndex)
        } catch let error {
            XCTFail()
        }
        
        // 2. Wrong data for fromRow
        do {
            try await moveHandler.onMove(
                from: IndexSet(integer: 10),
                to: 1,
                relationRows: [],
                document: mockDocument
            )
            XCTFail("Expected wrongDataForFromRow error")
        } catch let error as TypeFieldsMoveError {
            XCTAssertEqual(error, .wrongDataForFromRow)
        } catch let error {
            XCTFail()
        }
    }

    func testMoveBetweenSections() async throws {
        // Arrange
        let headerSection = TypeFieldsSectionRow.header
        let fieldsSection = TypeFieldsSectionRow.fieldsMenu
        
        let relation1 = Relation.mock(id: "relation1")
        let relation2 = Relation.mock(id: "relation2")
        let relation3 = Relation.mock(id: "relation3")
        
        let relationRows = [
            TypeFieldsRow.header(.header),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: relation1)),
            TypeFieldsRow.header(.fieldsMenu),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: relation2)),
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: fieldsSection, relation: relation3))
        ]
        
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["relation1"],
            recommendedRelations: ["relation2", "relation3"]
        )
        
        // Act
        try await moveHandler.onMove(
            from: IndexSet(integer: 1),
            to: 4,
            relationRows: relationRows,
            document: mockDocument
        )
        
        // Assert
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedRelationIds,
            ["relation2", "relation1", "relation3"]
        )
        XCTAssertEqual(
            mockRelationsService.lastUpdateTypeRelations?.recommendedFeaturedRelationsIds,
            []
        )
    }

    func testEdgeCaseWithEmptyDetails() async throws {
        // Arrange
        let headerSection = TypeFieldsSectionRow.header
        let relation1 = Relation.mock(id: "relation1")
        
        let relationRows = [
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: relation1))
        ]
        
        mockDocument.mockDetails = nil
        
        // Act & Assert
        try await moveHandler.onMove(
            from: IndexSet(integer: 0),
            to: 0,
            relationRows: relationRows,
            document: mockDocument
        )
        // No error should be thrown, and no service calls should be made
        XCTAssertNil(mockRelationsService.lastUpdateFeaturedRelations)
        XCTAssertNil(mockRelationsService.lastUpdateTypeRelations)
    }
}
