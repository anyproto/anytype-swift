import XCTest
import Services
@testable import Anytype

class TypeFieldsMoveHandlerTests: XCTestCase {
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

    func testErrorHandling() async {
        // Test invalid index error
        do {
            try await moveHandler.onMove(
                from: 10,
                to: 1,
                relationRows: [],
                document: mockDocument
            )
            XCTFail("Expected wrongDataForFromRow error")
        } catch let error as TypeFieldsMoveError {
            XCTAssertEqual(error, .wrongDataForFromRow)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
        
        // Test wrong data for fromRow
        let invalidRows = [TypeFieldsRow.header(.header)]
        do {
            try await moveHandler.onMove(
                from: 0,
                to: 1,
                relationRows: invalidRows,
                document: mockDocument
            )
            XCTFail("Expected wrongDataForFromRow error")
        } catch let error as TypeFieldsMoveError {
            XCTAssertEqual(error, .wrongDataForFromRow)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func testEdgeCaseWithEmptyDetails() async throws {
        // Arrange
        let headerSection = TypeFieldsSectionRow.header
        let relation1 = Relation.mock(id: "relation1")
        
        let relationRows = [
            TypeFieldsRow.relation(TypeFieldsRelationRow(section: headerSection, relation: relation1, canDrag: true))
        ]
        
        mockDocument.mockDetails = nil
        
        // Act & Assert
        try await moveHandler.onMove(
            from: 0,
            to: 0,
            relationRows: relationRows,
            document: mockDocument
        )
        // No error should be thrown, and no service calls should be made
        XCTAssertNil(mockRelationsService.lastUpdateFeaturedRelations)
        XCTAssertNil(mockRelationsService.lastUpdateTypeRelations)
    }
}
