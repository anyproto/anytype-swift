import UIKit

// TODO: add #if DEBUG
struct PageCellDataMock {
    static let data = [
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            iconData: .emoji("📘"),
            title: "Ubik",
            type: "Book"
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            iconData: .none,
            title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include",
            type: "Page"
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            iconData: .none,
            title: "GridItem",
            type: "Component"
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            iconData: .emoji("📘"),
            title: "Ubik",
            type: "Book"
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            iconData: .imageId("picpath"),
            title: "Neo",
            type: "Character"
        ),
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            iconData: .imageId("picpath"),
            title: "Neo",
            type: "Character"
        ),
        
        PageCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            iconData: .none,
            title: "Main",
            type: "Void"
        )
    ]
}
