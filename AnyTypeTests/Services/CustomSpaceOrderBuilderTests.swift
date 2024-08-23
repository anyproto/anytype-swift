import XCTest
@testable import Anytype


final class CustomSpaceOrderBuilderTests: XCTestCase {
    
    var builder: CustomSpaceOrderBuilderProtocol!
    var userDefaults: UserDefaultsStorageMock!

    override func setUpWithError() throws {
        userDefaults = UserDefaultsStorageMock()
        Container.shared.userDefaultsStorage.register { [weak self] in self!.userDefaults }
        builder = CustomSpaceOrderBuilder()
    }

    override func tearDownWithError() throws {
        builder = nil
        userDefaults = nil
    }

    @MainActor
    func testMove() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        builder.updateSpacesList(spaces: [one, two, three])
        
        builder.move(space: one, after: two)
        
        XCTAssertEqual(builder.allWorkspaces, [two, one, three])
    }
    
    @MainActor
    func testSeveralMoves() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        builder.updateSpacesList(spaces: [one, two, three])
        
        builder.move(space: one, after: two)
        builder.move(space: three, after: two)
        builder.move(space: two, after: one)
        
        XCTAssertEqual(builder.allWorkspaces, [three, one, two])
    }
    
    @MainActor
    func testMoveToTheSamePosition() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        builder.updateSpacesList(spaces: [one, two, three])
        
        builder.move(space: two, after: two)
        
        XCTAssertEqual(builder.allWorkspaces, [one, two, three])
    }
    
    @MainActor
    func testMoveTwice() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        builder.updateSpacesList(spaces: [one, two, three])
        
        builder.move(space: one, after: two)
        builder.move(space: two, after: three)
        
        XCTAssertEqual(builder.allWorkspaces, [one, three, two])
    }
    
    @MainActor
    func testSwapBack() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        builder.updateSpacesList(spaces: [one, two, three])
        
        builder.move(space: one, after: two)
        builder.move(space: two, after: one)
        
        XCTAssertEqual(builder.allWorkspaces, [one, two, three])
    }
    
    
    @MainActor
    func testAddNewSpaces() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        builder.updateSpacesList(spaces: [one, two])
        builder.move(space: one, after: two)
        builder.updateSpacesList(spaces: [one, two, three])
        
        XCTAssertEqual(builder.allWorkspaces, [three, two, one])
    }
    
    @MainActor
    func testRemoveSpaces() throws {
        let one = SpaceView.mock(id: 1)
        let two = SpaceView.mock(id: 2)
        let three = SpaceView.mock(id: 3)
        
        builder.updateSpacesList(spaces: [one, two, three])
        builder.move(space: one, after: two)
        builder.updateSpacesList(spaces: [three, one])
        
        XCTAssertEqual(builder.allWorkspaces, [one, three])
    }

}

extension SpaceView {
    static func mock(id: Int) -> SpaceView {
        mock(id: "\(id)")
    }
    
    static func mock(id: String) -> SpaceView {
        SpaceView(
            id: id,
            name: "Name \(id)",
            objectIconImage: nil,
            targetSpaceId: "Target\(id)",
            createdDate: .yesterday,
            accountStatus: .ok,
            localStatus: .ok,
            spaceAccessType: .private,
            readersLimit: nil,
            writersLimit: nil,
            sharedSpacesLimit: nil
        )
    }
}
