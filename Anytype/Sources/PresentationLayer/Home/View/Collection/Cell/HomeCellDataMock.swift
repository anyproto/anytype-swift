import UIKit
import AnytypeCore

struct HomeCellDataMock {
    static let data = [
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .emoji(Emoji("📘")!),
            title: .default(title: "Ubik"),
            type: "Book",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .none,
            title: .default(title: "The president’s American Family Plan, which remains in flux, does not currently include does not currently include does not currently include"),
            type: "Page",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .none,
            title: .default(title: "GridItem"),
            type: "Component",
            isLoading: true,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .emoji(Emoji("🤡")!),
            title: .todo(title: "DO IT!", isChecked: false),
            type: "Task",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .profile(.character("👽")),
            title: .default(title: "Neo"),
            type: "Character",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .none,
            title: .todo(title: "Relax", isChecked: true),
            type: "Character",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .none,
            title: .default(title: "Main"),
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .profile(.character("A")),
            title: .default(title: "Anton"),
            type: "Humanoid",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .none,
            title: .todo(title: "TodoTodoTodoTodoTodoTodoTodoTodoTodo", isChecked: true),
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: false,
            viewType: .page
        ),
        
        HomeCellData(
            id: "\(UUID())".asAnytypeId!,
            destinationId: "destinationId".asAnytypeId!,
            icon: .none,
            title: .todo(title: "TodoTodoTodoTodoTodoTodoTodoTodoTodo", isChecked: true),
            type: "Void",
            isLoading: false,
            isArchived: true,
            isDeleted: true,
            viewType: .page
        )
    ]
}
