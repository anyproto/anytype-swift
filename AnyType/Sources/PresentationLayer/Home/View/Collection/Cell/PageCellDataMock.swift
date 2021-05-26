import UIKit

// TODO: add #if DEBUG
struct PageCellDataMock {
    static let data = [
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .emoji(IconEmoji("📘")!),
            title: "Ubik",
            type: "Book",
            isLoading: false
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include",
            type: "Page",
            isLoading: false
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: "GridItem",
            type: "Component",
            isLoading: true
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .emoji(IconEmoji("📘")!),
            title: "Ubik",
            type: "Book",
            isLoading: false
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .imageId("1337"),
            title: "Neo",
            type: "Character",
            isLoading: false
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .imageId("1337"),
            title: "Neo",
            type: "Character",
            isLoading: false
        ),
        
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: "Main",
            type: "Void",
            isLoading: false
        )
    ]
}
