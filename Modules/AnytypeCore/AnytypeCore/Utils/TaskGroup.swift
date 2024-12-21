import Foundation

fileprivate struct SortedItem<ChildTaskResult> {
    let index: Int
    let content: ChildTaskResult
}

extension SortedItem: Sendable where ChildTaskResult: Sendable {}

public struct SortedTaskGroup<ChildTaskResult> where ChildTaskResult : Sendable {
    
    private var index: Int = 0
    
    fileprivate var taskGroup: TaskGroup<SortedItem<ChildTaskResult>>
    
    fileprivate init(taskGroup: TaskGroup<SortedItem<ChildTaskResult>>) {
        self.taskGroup = taskGroup
    }
    
    public mutating func addTask(priority: TaskPriority? = nil, operation: @escaping @Sendable () async -> ChildTaskResult) {
        let currentIndex = index
        taskGroup.addTask(priority: priority) { SortedItem(index: currentIndex, content: await operation()) }
        index += 1
    }
    
    public mutating func waitResult() async -> [ChildTaskResult] {
        let result = await taskGroup.reduce(into: [SortedItem<ChildTaskResult>]()) { partialResult, content in
            partialResult.append(content)
        }
        return result.sorted { $0.index < $1.index }.compactMap { $0.content }
    }
}

public func withSortedTaskGroup<ChildTaskResult, GroupResult>(
    of childTaskResultType: ChildTaskResult.Type,
    returning returnType: GroupResult.Type = GroupResult.self,
    body: (inout SortedTaskGroup<ChildTaskResult>) async -> GroupResult
) async -> GroupResult where ChildTaskResult : Sendable {
    await withTaskGroup(of: SortedItem<ChildTaskResult>.self, returning: GroupResult.self) { taskGroup in
        var sortedTaskGroup = SortedTaskGroup(taskGroup: taskGroup)
        return await body(&sortedTaskGroup)
    }
}
