extension EditorSetViewModel {
    func changePage(_ page: Int) {
        update(data: paginationHelper.changePage(page, data: pagitationData))
    }
    
    func updatePageCount(_ count: Int) {
        update(data: paginationHelper.updatePageCount(count, data: pagitationData))
    }
    
    func goForwardRow() {
        update(data: paginationHelper.goForwardRow(data: pagitationData))
    }
    
    func goBackwardRow() {
        update(data: paginationHelper.goBackwardRow(data: pagitationData))
    }
    
    private func update(data: EditorSetPaginationData?) {
        guard let data = data else { return }
        pagitationData = data
        startSubscriptionIfNeeded()
    }
}
