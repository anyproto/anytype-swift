@MainActor
protocol JoinBaseOutput: AnyObject {
    func onNext()
    func onBack()
    func onError(_ error: some Error)
    func disableBackAction(_ disable: Bool)
}
