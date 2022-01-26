extension EditorSetViewModel {
    func changePage(_ page: Int64) {
        update(data: paginationHelper.changePage(page, data: pagitationData))
    }
    
    func updatePageCount(_ count: Int64) {
        update(data: paginationHelper.updatePageCount(count, data: pagitationData))
    }
    
    func goForwardRow() {
        update(data: paginationHelper.goForwardRow(data: pagitationData))
    }
    
    func goBackwardRow() {
        update(data: paginationHelper.goBackwardRow(data: pagitationData))
    }
    
    private func update(data: EditorSetPaginationHelperData?) {
        guard let data = data else { return }
        pagitationData = data.data
        if data.shoudUpdateSubscription {
            setupSubscriptions()
        }
    }
}
