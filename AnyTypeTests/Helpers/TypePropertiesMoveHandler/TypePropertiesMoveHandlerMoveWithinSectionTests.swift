import XCTest
import Services
@testable import Anytype

class TypePropertiesMoveHandlerMoveWithinSectionTests: XCTestCase {
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

    // Header Section Movement Tests
    func testMoveWithinHeaderSectionFromStartToMiddle() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        // Moving h1 (index 1) to after h3 (index 3)
        try await moveHandler.onMove(
            from: 1,
            to: 3,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedFeaturedRelations?.relations.map(\.id),
            ["h2", "h3", "h1", "h4"]
        )
    }

    func testMoveWithinHeaderSectionFromStartToEnd() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: 1,
            to: 4,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedFeaturedRelations?.relations.map(\.id),
            ["h2", "h3", "h4", "h1"]
        )
    }

    func testMoveWithinHeaderSectionFromMiddleToStart() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: 2,
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedFeaturedRelations?.relations.map(\.id),
            ["h2", "h1", "h3", "h4"]
        )
    }

    func testMoveWithinHeaderSectionFromMiddleToEnd() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: 2,
            to: 4,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedFeaturedRelations?.relations.map(\.id),
            ["h1", "h3", "h4", "h2"]
        )
    }

    func testMoveWithinHeaderSectionFromEndToStart() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: 4,
            to: 1,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedFeaturedRelations?.relations.map(\.id),
            ["h4", "h1", "h2", "h3"]
        )
    }

    func testMoveWithinHeaderSectionFromEndToMiddle() async throws {
        let relationRows = createHeaderSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedFeaturedRelations: ["h1", "h2", "h3", "h4"]
        )
        
        try await moveHandler.onMove(
            from: 4,
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedFeaturedRelations?.relations.map(\.id),
            ["h1", "h4", "h2", "h3"]
        )
    }

    // Fields Section Movement Tests
    func testMoveWithinFieldsSectionFromStartToMiddle() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: 2,
            to: 4,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedRelations?.relations.map(\.id),
            ["f2", "f3", "f1", "f4"]
        )
    }

    func testMoveWithinFieldsSectionFromStartToEnd() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: 2,
            to: 5,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedRelations?.relations.map(\.id),
            ["f2", "f3", "f4", "f1"]
        )
    }

    func testMoveWithinFieldsSectionFromMiddleToStart() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: 3,
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedRelations?.relations.map(\.id),
            ["f2", "f1", "f3", "f4"]
        )
    }

    func testMoveWithinFieldsSectionFromMiddleToEnd() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: 3,
            to: 5,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedRelations?.relations.map(\.id),
            ["f1", "f3", "f4", "f2"]
        )
    }

    func testMoveWithinFieldsSectionFromEndToStart() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: 5,
            to: 2,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedRelations?.relations.map(\.id),
            ["f4", "f1", "f2", "f3"]
        )
    }

    func testMoveWithinFieldsSectionFromEndToMiddle() async throws {
        let relationRows = createFieldsSectionRows()
        mockDocument.mockDetails = ObjectDetails.mock(
            recommendedRelations: ["f1", "f2", "f3", "f4"]
        )
        
        try await moveHandler.onMove(
            from: 5,
            to: 3,
            relationRows: relationRows,
            document: mockDocument
        )
        
        XCTAssertEqual(
            mockPropertiesService.lastUpdateRecommendedRelations?.relations.map(\.id),
            ["f1", "f4", "f2", "f3"]
        )
    }

    // Helper methods
    private func createHeaderSectionRows() -> [TypePropertiesRow] {
        let headerSection = TypePropertiesSectionRow.header
        return [
            .header(.header),
            .relation(TypePropertiesRelationRow(section: headerSection, relation: .mock(id: "h1"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: headerSection, relation: .mock(id: "h2"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: headerSection, relation: .mock(id: "h3"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: headerSection, relation: .mock(id: "h4"), canDrag: true)),
            .header(.fieldsMenu)
        ]
    }

    private func createFieldsSectionRows() -> [TypePropertiesRow] {
        let fieldsSection = TypePropertiesSectionRow.fieldsMenu
        return [
            .header(.header),
            .header(.fieldsMenu),
            .relation(TypePropertiesRelationRow(section: fieldsSection, relation: .mock(id: "f1"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: fieldsSection, relation: .mock(id: "f2"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: fieldsSection, relation: .mock(id: "f3"), canDrag: true)),
            .relation(TypePropertiesRelationRow(section: fieldsSection, relation: .mock(id: "f4"), canDrag: true))
        ]
    }
}
