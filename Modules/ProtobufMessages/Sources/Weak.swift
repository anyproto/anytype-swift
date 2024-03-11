final class WeakHandler {
    weak var value: ServiceEventsHandlerProtocol?
    init (_ value: ServiceEventsHandlerProtocol) {
        self.value = value
    }
}
