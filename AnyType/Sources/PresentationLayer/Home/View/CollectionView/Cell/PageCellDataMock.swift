import UIKit

// TODO: add #if DEBUG
struct PageCellDataMock {
    static let data = [
        PageCellData(
            id: "\(UUID())",
            iconData: .emoji("📘"),
            title: "Ubik",
            type: "Book"
        ),
        PageCellData(
            id: "\(UUID())",
            iconData: .none,
            title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include",
            type: "Page"
        ),
        PageCellData(
            id: "\(UUID())",
            iconData: .none,
            title: "GridItem",
            type: "Component"
        ),
        PageCellData(
            id: "\(UUID())",
            iconData: .emoji("📘"),
            title: "Ubik",
            type: "Book"
        ),
        PageCellData(
            id: "\(UUID())",
            iconData: .imageId("picpath"),
            title: "Neo",
            type: "Character"
        ),
        PageCellData(
            id: "\(UUID())",
            iconData: .imageId("picpath"),
            title: "Neo",
            type: "Character"
        ),
        
        PageCellData(
            id: "\(UUID())",
            iconData: .none,
            title: "Main",
            type: "Void"
        )
    ]
}
