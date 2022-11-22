extension EditorSetViewModel {

    func showMore(groupId: String) {
        guard let pagitationData = pagitationDataDict[groupId] else { return }
        let page = pagitationData.selectedPage + 1
        update(data: paginationHelper.changePage(page, data: pagitationData, ignorePageLimit: true), groupId: groupId)
    }
    
    func changePage(_ page: Int, groupId: String) {
        guard let pagitationData = pagitationDataDict[groupId] else { return }
        update(data: paginationHelper.changePage(page, data: pagitationData), groupId: groupId)
    }
    
    func updatePageCount(_ count: Int, groupId: String, ignorePageLimit: Bool) {
        guard let pagitationData = pagitationDataDict[groupId] else { return }
        update(data: paginationHelper.updatePageCount(count, data: pagitationData, ignorePageLimit: ignorePageLimit), groupId: groupId)
    }
    
    func goForwardRow(groupId: String) {
        guard let pagitationData = pagitationDataDict[groupId] else { return }
        update(data: paginationHelper.goForwardRow(data: pagitationData), groupId: groupId)
    }
    
    func goBackwardRow(groupId: String) {
        guard let pagitationData = pagitationDataDict[groupId] else { return }
        update(data: paginationHelper.goBackwardRow(data: pagitationData), groupId: groupId)
    }
    
    private func update(data: EditorSetPaginationHelperData?, groupId: String) {
        guard let data = data else { return }
        pagitationDataDict[groupId] = data.data
        if data.shoudUpdateSubscription {
            startSubscriptionIfNeeded()
        }
    }
}
