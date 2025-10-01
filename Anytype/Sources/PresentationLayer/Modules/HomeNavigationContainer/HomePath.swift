import Foundation
import AnytypeCore
import SwiftUI

struct HomePath: Equatable, @unchecked Sendable {
    
    fileprivate(set) var path: [AnyHashable]
    
    init(initialPath: [AnyHashable] = []) {
        path = initialPath
    }
    
    var count: Int {
        path.count
    }
        
    mutating func push(_ item: AnyHashable) {
        path.append(item)
    }
    
    mutating func pop() {
        guard path.count > 1 else { return }
        _ = path.popLast()
    }
    
    mutating func popToRoot() {
        guard let first = path.first else { return }
        path = [first]
    }
    
    mutating func popToFirstOpened() {
        guard let first = path[safe: 0] else { return }
        guard let second = path[safe: 1] else { return }
        path = [first, second]
    }
    
    mutating func replaceLast(_ item: AnyHashable) {
        guard path.count > 0 else {
            anytypeAssertionFailure("Path is 0")
            return
        }
        path[path.count-1] = item
    }
    
    mutating func popTo(_ item: AnyHashable) {
        if let index = path.firstIndex(where: { $0 == item }) {
            path = Array(path[...index])
        }
    }
    
    func contains(_ item: AnyHashable) -> Bool {
        path.contains(where: { $0 == item })
    }
    
    func index(_ item: AnyHashable) -> Int? {
        path.firstIndex(where: { $0 == item })
    }
    
    mutating func insert(_ item: AnyHashable, at index: Int) {
        path.insert(item, at: index)
    }
    
    mutating func remove(_ item: AnyHashable) {
        path.removeAll { $0 == item }
    }
    
    mutating func openOnce(_ item: AnyHashable) {
        if contains(item) {
            popTo(item)
        } else {
            push(item)
        }
    }
    
    var lastPathElement: AnyHashable? {
        path.last
    }
}

extension AnytypeNavigationView {

    init(path homePath: Binding<HomePath>, pathChanging: Binding<Bool>, moduleSetup: @escaping (_ builder: AnytypeDestinationBuilderHolder) -> Void) {
        let path = Binding(
            get: { homePath.wrappedValue.path },
            set: { homePath.wrappedValue.path = $0 }
        )
        self.init(path: path, pathChanging: pathChanging, moduleSetup: moduleSetup)
    }
}
