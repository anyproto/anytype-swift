import Foundation
import AnytypeCore
import SwiftUI

struct HomePath: Equatable {
    
    private(set) var forwardPath: [AnyHashable] = []
    
    fileprivate(set) var path: [AnyHashable] {
        didSet { didChangePath(newPath: path, oldPath: oldValue) }
    }
    
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
    
    mutating func pushFromHistory() {
        guard let item = forwardPath.last else { return }
        path.append(item)
    }
    
    mutating func popTo(_ item: AnyHashable) {
        if let index = path.firstIndex(where: { $0 == item }) {
            path = Array(path[...index])
        }
    }
    
    func contains(_ item: AnyHashable) -> Bool {
        path.contains(where: { $0 == item })
    }
    
    func hasForwardPath() -> Bool {
        return forwardPath.isNotEmpty
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
    
    // MARK: - Private
    
    private mutating func didChangePath(newPath: [AnyHashable], oldPath: [AnyHashable]) {
        
        if oldPath.count > newPath.count {
            // Pop
            let oldSubPath = oldPath[newPath.count...].reversed()
            forwardPath.append(contentsOf: oldSubPath)
        } else if oldPath.count < newPath.count {
            // Push
            let newSubPath = newPath[oldPath.count...].reversed()
            guard forwardPath.count >= newSubPath.count, newSubPath.count > 0 else { return }
            let currentForwardSubpath = forwardPath.suffix(newSubPath.count)
            if Array(newSubPath) != Array(currentForwardSubpath) {
                forwardPath.removeAll()
            } else {
                forwardPath.removeLast(newSubPath.count)
            }
        }
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
