import Foundation
import AnytypeCore
import SwiftUI

struct HomePath {
    
    private var forwardPath: [AnyHashable] = []
    
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
            path.append(page)
        }
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
    
    mutating func replaceLast(_ item: AnyHashable) {
        guard path.count > 0 else {
            anytypeAssertionFailure("Path is 0")
            return
        }
        path[path.count-1] = item
    }
    
    mutating func pushFromHistory() {
        guard let item = forwardPath.first else { return }
        path.append(item)
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

extension AnytypeNavigationView {

    init(path homePath: Binding<HomePath>, moduleSetup: @escaping (_ builder: AnytypeDestinationBuilderHolder) -> Void) {
        let path = Binding(
            get: { homePath.wrappedValue.path },
            set: { homePath.wrappedValue.path = $0 }
        )
        self.init(path: path, moduleSetup: moduleSetup)
    }
}
