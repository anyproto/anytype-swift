import AnytypeCore
struct EditorSetPaginationHelperData {
    let data: EditorSetPaginationData
    let shoudUpdateSubscription: Bool
    
    init(data: EditorSetPaginationData, shoudUpdateSubscription: Bool = false) {
        self.data = data
        self.shoudUpdateSubscription = shoudUpdateSubscription
    }
}

final class EditorSetPaginationHelper {
    private let numberOfPagesPerRow: Int64 = 5
    
    func changePage(_ page: Int64, data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        guard page != data.selectedPage else { return nil }
        guard page <= data.pageCount else { return nil }
        return EditorSetPaginationHelperData(
            data: data.updated(selectedPage: page),
            shoudUpdateSubscription: true
        )
    }
    
    func goForwardRow(data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        guard data.canGoForward else { return nil }
        guard let lastVisiblePage = data.visiblePages.last else { return nil }
        
        var newVisiblePages = [Int64]()
        for page in (lastVisiblePage + 1)...(lastVisiblePage + numberOfPagesPerRow) {
            guard page <= data.pageCount else { continue }
            newVisiblePages.append(page)
        }
        
        let data = data.updated(visiblePages: newVisiblePages)
        return EditorSetPaginationHelperData(data: data)
    }
    
    func goBackwardRow(data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        guard data.canGoBackward else { return nil }
        guard let firstVisiblePage = data.visiblePages.first else { return nil }
        
        var newVisiblePages = [Int64]()
        for page in (firstVisiblePage - numberOfPagesPerRow)...(firstVisiblePage - 1) {
            guard page >= 1 else { continue }
            newVisiblePages.append(page)
        }
        
        let data = data.updated(visiblePages: newVisiblePages)
        return EditorSetPaginationHelperData(data: data)
    }
    
    func updatePageCount(_ count: Int64, data: EditorSetPaginationData) -> EditorSetPaginationHelperData? {
        var data = data
        data = updateVisiblePagesPage(count: count, data: data)
        data = data.updated(pageCount: count)
        
        let noNeedToChangeCurrentPage = data.selectedPage <= data.pageCount
        guard noNeedToChangeCurrentPage else {
            return changePage(data.pageCount, data: data)
        }
        
        return EditorSetPaginationHelperData(data: data)
    }
    
    private func updateVisiblePagesPage(count: Int64, data: EditorSetPaginationData) -> EditorSetPaginationData {
        guard let lastPage = data.visiblePages.last else {
            anytypeAssertionFailure("Empty pagination data", domain: .editorSetPagination)
            return data
        }
        
        if lastPage <= count {
            guard data.visiblePages.count < numberOfPagesPerRow else { return data }
            return addPages(count: count, data: data, lastPage: lastPage)
        } else {
            return removePages(count: count, data: data)
        }
    }
    
    func addPages(count: Int64, data: EditorSetPaginationData, lastPage: Int64) -> EditorSetPaginationData {
        var newVisiblePages = [Int64]()
        let numberOfPagesToTheClosestNumberDivisibleByFive = lastPage % numberOfPagesPerRow == 0 ? numberOfPagesPerRow : lastPage % numberOfPagesPerRow
        let lowerBound = lastPage - numberOfPagesToTheClosestNumberDivisibleByFive + 1
        
        let upperBound = min(count, lowerBound + numberOfPagesPerRow - 1)
        for page in lowerBound...upperBound {
            newVisiblePages.append(page)
        }
        
        return data.updated(visiblePages: newVisiblePages)
    }
    
    func removePages(count: Int64, data: EditorSetPaginationData) -> EditorSetPaginationData {
        var newVisiblePages = [Int64]()
        let numberOfPagesToTheClosestNumberDivisibleByFive = count % numberOfPagesPerRow == 0 ? numberOfPagesPerRow : count % numberOfPagesPerRow
        let lowerBound = count - numberOfPagesToTheClosestNumberDivisibleByFive + 1
        for page in lowerBound...count {
            newVisiblePages.append(page)
        }
        
        return data.updated(visiblePages: newVisiblePages)
    }
}
