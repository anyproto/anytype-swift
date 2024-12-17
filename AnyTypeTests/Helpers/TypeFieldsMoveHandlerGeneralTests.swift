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
