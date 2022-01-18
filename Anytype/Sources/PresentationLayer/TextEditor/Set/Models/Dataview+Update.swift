import BlocksModels
import AnytypeCore

extension BlockDataview {
    func updated(_ update: DataviewUpdate) -> BlockDataview {
        switch update {
        case .set(let view):
            guard let index = views.firstIndex(where: { $0.id == view.id }) else { return self }
            var newViews = views
            newViews[index] = view
            return BlockDataview(source: source, views: newViews, relations: relations)
        case .order(let ids):
            let newViews = ids.compactMap { id -> DataviewView? in
                guard let view = views.first(where: { $0.id == id }) else {
                    anytypeAssertionFailure("Not found view with id: \(id)", domain: .dataviewConverter)
                    return nil
                }
                return view
            }
            return BlockDataview(source: source, views: newViews, relations: relations)
        }
    }
}
