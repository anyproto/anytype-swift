enum BlockToolbarAddBlockViewModelBuilder {
    static func create() -> BlockToolbarAddBlockViewModel {
        let viewModel: BlockToolbarAddBlockViewModel = .init()
        _ = viewModel.nestedCategories.allText()
        _ = viewModel.nestedCategories.allList()
        _ = viewModel.nestedCategories.objects([.page, .file, .picture, .video, .bookmark])
        _ = viewModel.nestedCategories.other([.lineDivider, .dotsDivider, .code])
        _ = viewModel.configured(title: "Add Block")
        return viewModel
    }
}
