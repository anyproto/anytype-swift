import UIKit

// TODO: add #if DEBUG
struct HomeCellDataMock {
    static let data = [
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .emoji(IconEmoji("📘")!),
            title: .default(title: "Ubik"),
            type: "Book",
            isLoading: false,
            isArchived: true
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .default(title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include"),
            type: "Page",
            isLoading: false,
            isArchived: true
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .default(title: "GridItem"),
            type: "Component",
            isLoading: true,
            isArchived: true
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .emoji(IconEmoji("📘")!),
            title: .default(title: "Ubik"),
            type: "Book",
            isLoading: false,
            isArchived: true
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .profile(.imageId("1337")),
            title: .default(title: "Neo"),
            type: "Character",
            isLoading: false,
            isArchived: true
        ),
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .basic("1337"),
            title: .default(title: "Neo"),
            type: "Character",
            isLoading: false,
            isArchived: true
        ),
        
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .default(title: "Main"),
            type: "Void",
            isLoading: false,
            isArchived: true
        ),
        
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .todo(title: "Todo", isChecked: false),
            type: "Void",
            isLoading: false,
            isArchived: true
        ),
        
        HomeCellData(
            id: "\(UUID())",
            destinationId: "destinationId",
            icon: .none,
            title: .todo(title: "TodoTodoTodoTodoTodoTodoTodoTodoTodo", isChecked: true),
            type: "Void",
            isLoading: false,
            isArchived: true
        )
    ]
}
