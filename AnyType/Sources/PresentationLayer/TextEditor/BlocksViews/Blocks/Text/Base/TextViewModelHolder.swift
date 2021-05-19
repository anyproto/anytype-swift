
final class TextViewModelHolder {
    private var viewModel: BlockTextViewModel?

    init(_ viewModel: BlockTextViewModel?) {
        self.viewModel = viewModel
    }

    func cleanup() {
        self.viewModel = nil
    }

    func apply(_ update: BlockTextViewModel.Update) {
        if let viewModel = self.viewModel {
            viewModel.update = update
        }
    }
}
