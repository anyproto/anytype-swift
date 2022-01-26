struct EditorSetPaginationHelperData {
    let data: EditorSetPaginationData
    let shoudUpdateSubscription: Bool
    
    init(data: EditorSetPaginationData, shoudUpdateSubscription: Bool = false) {
        self.data = data
        self.shoudUpdateSubscription = shoudUpdateSubscription
    }
}

final class EditorSetPaginationHelper {
    
    func changePage(_ page: Int, data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        guard page != data.selectedPage else { return nil }
        guard page <= data.pageCount else { return nil }
        return EditorSetPaginationHelperData(
            data: data.updated(selectedPage: page),
            shoudUpdateSubscription: true
        )
    }
    
    func updatePageCount(_ count: Int64, data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        var data = data
        let isLastPage = data.visiblePages.last.flatMap { $0 == data.pageCount } ?? true
        if isLastPage {
            var newVisiblePages = [Int]()
            for page in (count - (count % 5) + 1)...count {
                newVisiblePages.append(Int(page))
            }
            
            data = data.updated(visiblePages: newVisiblePages)
        }
        
        data = data.updated(pageCount: count)
        
        guard data.selectedPage >= data.pageCount else {
            return changePage(Int(data.pageCount), data: data)
        }
        
        return EditorSetPaginationHelperData(data: data)
    }
    
    func goForwardPage(data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        guard data.canGoForward else { return nil }
        guard let lastVisiblePage = data.visiblePages.last else { return nil }
        
        var newVisiblePages = [Int]()
        for page in (lastVisiblePage + 1)...(lastVisiblePage + 5) {
            guard page <= data.pageCount else { continue }
            newVisiblePages.append(page)
        }
        
        let data = data.updated(visiblePages: newVisiblePages)
        return EditorSetPaginationHelperData(data: data)
    }
    
    func goBackwardPage(data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        guard data.canGoBackward else { return nil }
        guard let firstVisiblePage = data.visiblePages.first else { return nil }
        
        var newVisiblePages = [Int]()
        for page in (firstVisiblePage - 5)...(firstVisiblePage - 1) {
            guard page >= 1 else { continue }
            newVisiblePages.append(page)
        }
        
        let data = data.updated(visiblePages: newVisiblePages)
        return EditorSetPaginationHelperData(data: data)
    }
}
