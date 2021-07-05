import UIKit

// TODO: add #if DEBUG
struct PageCellDataMock {
    static let data = [
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .basic(.emoji(IconEmoji("📘")!)),
            title: "Ubik",
            type: "Book",
            isLoading: false,
            isArchived: true
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include",
            type: "Page",
            isLoading: false,
            isArchived: true
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: "GridItem",
            type: "Component",
            isLoading: true,
            isArchived: true
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .basic(.emoji(IconEmoji("📘")!)),
            title: "Ubik",
            type: "Book",
            isLoading: false,
            isArchived: true
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .profile(.imageId("1337")),
            title: "Neo",
            type: "Character",
            isLoading: false,
            isArchived: true
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .basic(.imageId("1337")),
            title: "Neo",
            type: "Character",
            isLoading: false,
            isArchived: true
        ),
        
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: "Main",
            type: "Void",
            isLoading: false,
            isArchived: true
        )
    ]
}
