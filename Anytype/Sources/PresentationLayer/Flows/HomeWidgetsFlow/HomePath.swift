import Foundation
import AnytypeCore
import SwiftUI
import NavigationBackport

final class NavigationExecutionChecker {
    private var oldExecutionDate = Date(timeIntervalSince1970: 0)
    
    func execute() -> Bool {
        return true
//        let canExecute = Date().timeIntervalSince(oldExecutionDate) > 0.7
//        if canExecute {
//            oldExecutionDate = Date()
//        }
//        return canExecute
    }
}

struct HomePath {
    
    private var forwardPath: [AnyHashable] = []
    private var checker = NavigationExecutionChecker()
    
    fileprivate var path: [AnyHashable] = [] {
        didSet { didChangePath(newPath: path, oldPath: oldValue) }
    }
    
    var count: Int {
        path.count
    }
    
    // From ios 16 delete NavigationBackport and restore path in init.
    @available(iOS, deprecated: 16)
    mutating func restoreLastOpenPage() {
        if let page = UserDefaultsConfig.lastOpenedPage {
            path.push(page)
            _ = checker.execute()
        }
    }
    
    mutating func push(_ item: AnyHashable) {
        guard checker.execute() else { return }
        path.push(item)
    }
    
    mutating func pop() {
        guard checker.execute(), path.count > 1 else { return }
        _ = path.popLast()
    }
    
    mutating func popToRoot() {
        guard checker.execute(), let first = path.first else { return }
        path = [first]
    }
    
    mutating func replaceLast(_ item: AnyHashable) {
        guard checker.execute() else { return }
        guard path.count > 0 else {
            anytypeAssertionFailure("Path is 0")
            return
        }
        path[path.count-1] = item
    }
    
    mutating func pushFromHistory() {
        guard checker.execute() else { return }
        guard let item = forwardPath.first else { return }
        path.push(item)
    }
    
    mutating func replaceAll(_ item: AnyHashable) {
        path = [item]
    }
    
    func hasForwardPath() -> Bool {
        return forwardPath.isNotEmpty
    }
    
    // MARK: - Private
    
    private mutating func didChangePath(newPath: [AnyHashable], oldPath: [AnyHashable]) {
        UserDefaultsConfig.lastOpenedPage = newPath.last as? EditorScreenData
        
        if oldPath.count > newPath.count {
            // Pop
            let oldSubPath = oldPath[newPath.count...].reversed()
            forwardPath.insert(contentsOf: oldSubPath, at: 0)
        } else if oldPath.count < newPath.count {
            // Push
            let newSubPath = newPath[oldPath.count...].reversed()
            guard forwardPath.count >= newSubPath.count, newSubPath.count > 0 else { return }
            let currentForwardSubpath = forwardPath[...(newSubPath.count-1)]
            if Array(newSubPath) != Array(currentForwardSubpath) {
                forwardPath.removeAll()
            }
        }
    }
}

extension NBNavigationStack where Data == AnyHashable {

    init(path: Binding<HomePath>, @ViewBuilder root: () -> Root) {
        let path = Binding(
            get: { path.wrappedValue.path },
            set: { path.wrappedValue.path = $0 }
        )
        self.init(path: path, root: root)
    }
}

extension AnytypeNavigationView {

    init(path homePath: Binding<HomePath>, moduleSetup: @escaping (_ builder: AnytypeDestinationBuilderHolder) -> Void) {
        let path = Binding(
            get: { homePath.wrappedValue.path },
            set: { homePath.wrappedValue.path = $0 }
        )
        self.init(path: path, moduleSetup: moduleSetup)
    }
}
