import AnytypeCore

extension HomeViewModel {
    var isSelectionMode: Bool { binCellData.filter { $0.selected }.isNotEmpty }
    var isAllSelected: Bool { binCellData.first { !$0.selected }.isNil }
    var numberOfSelectedPages: Int { binCellData.filter { $0.selected }.count }
    
    func selectAll(_ select: Bool) {
        binCellData.indices.forEach { index in
            binCellData[index].selected = select
        }
    }
    
    func select(data: HomeCellData) {
        guard let index = binCellData.firstIndex(where: { $0.id == data.id }) else {
            anytypeAssertionFailure("No page in bin for data: \(data)")
            return
        }
        
        binCellData[index].selected.toggle()
    }
}
