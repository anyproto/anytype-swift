protocol CreateObjectViewModelProtocol {
    var style: CreateObjectView.Style { get }
    
    func textDidChange(_ text: String)
    func actionButtonTapped(with text: String)
    func returnDidTap()
}
