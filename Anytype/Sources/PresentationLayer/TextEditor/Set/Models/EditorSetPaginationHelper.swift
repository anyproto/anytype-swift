import AnytypeCore

final class EditorSetPaginationHelper {
    private let numberOfPagesPerRow: Int = 5
    
    func changePage(_ page: Int, data: EditorSetPaginationData) -> EditorSetPaginationData? {
        guard page != data.selectedPage else { return nil }
        guard page <= data.pageCount else { return nil }
        return data.updated(selectedPage: page)
    }
    
    func goForwardRow(data: EditorSetPaginationData) -> EditorSetPaginationData? {
        guard data.canGoForward else { return nil }
        guard let lastVisiblePage = data.visiblePages.last else { return nil }
        
        var newVisiblePages = [Int]()
        for page in (lastVisiblePage + 1)...(lastVisiblePage + numberOfPagesPerRow) {
            guard page <= data.pageCount else { continue }
            newVisiblePages.append(page)
        }
        
        return data.updated(visiblePages: newVisiblePages)
    }
    
    func goBackwardRow(data: EditorSetPaginationData) -> EditorSetPaginationData? {
        guard data.canGoBackward else { return nil }
        guard let firstVisiblePage = data.visiblePages.first else { return nil }
        
        var newVisiblePages = [Int]()
        for page in (firstVisiblePage - numberOfPagesPerRow)...(firstVisiblePage - 1) {
            guard page >= 1 else { continue }
            newVisiblePages.append(page)
        }
        
        return data.updated(visiblePages: newVisiblePages)
    }
    
    func updatePageCount(_ count: Int, data: EditorSetPaginationData) -> EditorSetPaginationData? {
        guard count != 0 else { return .empty}
        
        var data = data
        data = updateVisiblePagesPage(count: count, data: data)
        data = data.updated(pageCount: count)
        
        if data.selectedPage == 0 {
            return changePage(1, data: data)
        } else if data.selectedPage > data.pageCount {
            return changePage(data.pageCount, data: data)
        } else {
            return data
        }
    }
    
    private func updateVisiblePagesPage(count: Int, data: EditorSetPaginationData) -> EditorSetPaginationData {
        let lastPage = data.visiblePages.last ?? 0
        
        if lastPage <= count {
            guard data.visiblePages.count < numberOfPagesPerRow else { return data }
            return addPages(count: count, data: data, lastPage: lastPage)
        } else {
            return removePages(count: count, data: data)
        }
    }
    
    func addPages(count: Int, data: EditorSetPaginationData, lastPage: Int) -> EditorSetPaginationData {
        var newVisiblePages = [Int]()
        let lowerBound = lastPage - numberOfPagesToTheClosestNumberDivisibleByNumberOfPagesPerRow(lastPage) + 1
        
        let upperBound = min(count, lowerBound + numberOfPagesPerRow - 1)
        for page in lowerBound...upperBound {
            newVisiblePages.append(page)
        }
        
        return data.updated(visiblePages: newVisiblePages)
    }
    
    func removePages(count: Int, data: EditorSetPaginationData) -> EditorSetPaginationData {
        var newVisiblePages = [Int]()
        let lowerBound = count - numberOfPagesToTheClosestNumberDivisibleByNumberOfPagesPerRow(count) + 1
        for page in lowerBound...count {
            newVisiblePages.append(page)
        }
        
        return data.updated(visiblePages: newVisiblePages)
    }
    
    func numberOfPagesToTheClosestNumberDivisibleByNumberOfPagesPerRow(_ number: Int) -> Int {
        guard number != 0 else {
            return 0
        }
        return number % numberOfPagesPerRow == 0 ? numberOfPagesPerRow : number % numberOfPagesPerRow
    }
}
