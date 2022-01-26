extension EditorSetViewModel {
    func changePage(_ page: Int) {
        update(data: paginationHelper.changePage(page, data: pagitationData))
    }
    
    func updatePageCount(_ count: Int64) {
        update(data: paginationHelper.updatePageCount(count, data: pagitationData))
    }
    
    func goForwardPage() {
        update(data: paginationHelper.goForwardPage(data: pagitationData))
    }
    
    func goBackwardPage() {
        update(data: paginationHelper.goBackwardPage(data: pagitationData))
    }
    
    private func update(data: EditorSetPaginationHelperData?) {
        guard let data = data else { return }
        pagitationData = data.data
        if data.shoudUpdateSubscription {
            setupSubscriptions()
        }
    }
}
