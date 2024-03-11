extension EditorSetViewModel {

    func showMore(groupId: String) {
        guard let pagitationData = pagitationDataDict[groupId] else { return }
        let page = pagitationData.selectedPage + 1
        update(data: paginationHelper.changePage(page, data: pagitationData, ignorePageLimit: true), groupId: groupId)
    }
    
    func changePage(_ page: Int) {
        guard let pagitationData = pagitationDataDict[subscriptionId] else { return }
        update(data: paginationHelper.changePage(page, data: pagitationData), groupId: subscriptionId)
    }
    
    func updatePageCount(_ count: Int, groupId: String, ignorePageLimit: Bool) {
        guard let pagitationData = pagitationDataDict[groupId], pagitationData.pageCount != count else { return }
        update(data: paginationHelper.updatePageCount(count, data: pagitationData, ignorePageLimit: ignorePageLimit), groupId: groupId)
    }
    
    func goForwardRow() {
        guard let pagitationData = pagitationDataDict[subscriptionId] else { return }
        update(data: paginationHelper.goForwardRow(data: pagitationData), groupId: subscriptionId)
    }
    
    func goBackwardRow() {
        guard let pagitationData = pagitationDataDict[subscriptionId] else { return }
        update(data: paginationHelper.goBackwardRow(data: pagitationData), groupId: subscriptionId)
    }
    
    private func update(data: EditorSetPaginationHelperData?, groupId: String) {
        guard let data = data else { return }
        pagitationDataDict[groupId] = data.data
        if data.shoudUpdateSubscription {
            Task {
                await startSubscriptionIfNeeded(forceUpdate: true)
            }
        }
    }
}
