import UIKit
import AnytypeCore

struct HomeCellDataMock {
    static let data = [
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .icon(.emoji(Emoji("📘")!)),
            title: "Ubik",
            titleLayout: .vertical,
            type: "Book",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .none,
            title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include",
            titleLayout: .vertical,
            type: "Page",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .none,
            title: "GridItem",
            titleLayout: .vertical,
            type: "Component",
            isLoading: true,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .todo(false),
            title: "DO IT!",
            titleLayout: .horizontal,
            type: "Task",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .icon(.profile(.character("👽"))),
            title: "Neo",
            titleLayout: .vertical,
            type: "Character",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .todo(true),
            title: "Relax",
            titleLayout: .horizontal,
            type: "Character",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .none,
            title: "Main",
            titleLayout: .vertical,
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .icon(.profile(.character("A"))),
            title: "Anton",
            titleLayout: .vertical,
            type: "Humanoid",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .todo(false),
            title: "TodoTodoTodoTodoTodoTodoTodoTodoTodo",
            titleLayout: .horizontal,
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            isFavorite: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: UUID().uuidString,
            destinationId: "destinationId",
            icon: .todo(true),
            title: "TodoTodoTodoTodoTodoTodoTodoTodoTodo",
            titleLayout: .vertical,
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: true,
            isFavorite: false,
            viewType: .page
        )
    ]
}
