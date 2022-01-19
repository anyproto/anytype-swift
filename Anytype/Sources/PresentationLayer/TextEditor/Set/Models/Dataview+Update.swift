import BlocksModels
import AnytypeCore
import SwiftUI

extension EditorSetViewModel {
    func update(_ update: DataviewUpdate) {
        withAnimation(update.shouldAnimate ? .default : nil) {
            updateModel(update)
        }
    }
    
    private func updateModel(_ update: DataviewUpdate) {
        switch update {
        case .set(let view):
            let index = dataView.views.firstIndex(where: { $0.id == view.id }) ?? dataView.views.count
            var newViews = dataView.views
            newViews.insert(view, at: index)
            self.dataView = BlockDataview(source: dataView.source, views: newViews, relations: dataView.relations)
        case .order(let ids):
            let newViews = ids.compactMap { id -> DataviewView? in
                guard let view = dataView.views.first(where: { $0.id == id }) else {
                    anytypeAssertionFailure("Not found view in order with id: \(id)", domain: .dataviewConverter)
                    return nil
                }
                return view
            }
            dataView = BlockDataview(source: dataView.source, views: newViews, relations: dataView.relations)
        case .delete(id: let viewId):
            guard let view = dataView.views.first(where: { $0.id == viewId }), let index = dataView.views.firstIndex(of: view) else {
                anytypeAssertionFailure("Not found view in delete with id: \(viewId)", domain: .dataviewConverter)
                return
            }
            
            if view.id == activeViewId {
                if let newId = dataView.views.findNextSupportedView(mainIndex: index)?.id {
                    activeViewId = newId
                }
            }
            
            var newViews = dataView.views
            newViews.remove(at: index)
            dataView = BlockDataview(source: dataView.source, views: newViews, relations: dataView.relations)
        }
    }
}

extension Array where Element == DataviewView {
    // Looking forward first, then backward
    func findNextSupportedView(mainIndex: Int) -> DataviewView? {
        guard indices.contains(mainIndex) else { return nil }
        
        for index in (mainIndex + 1..<count) {
            if self[index].isSupported {
                return self[index]
            }
        }
        for index in (0..<mainIndex).reversed() {
            if self[index].isSupported {
                return self[index]
            }
        }
        
        return nil
    }
}
