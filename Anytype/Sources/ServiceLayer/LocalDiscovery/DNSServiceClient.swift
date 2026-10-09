import Foundation
import dnssd

struct DNSServiceError: Error, Equatable {
    let code: Int32
}

enum DNSServiceErrorCode {
    static let noError: Int32 = 0
    static let nameConflict: Int32 = -65548
    static let serviceNotRunning: Int32 = -65563
    static let defunctConnection: Int32 = -65569
    static let policyDenied: Int32 = -65570
}

enum DNSServiceRegisterEvent: Equatable {
    case registered(name: String)
    /// The daemon withdrew a registered name after the fact (a late conflict).
    case withdrawn
    case failed(DNSServiceError)
}

struct DNSServiceBrowseEvent: Equatable {
    let isAdded: Bool
    let interfaceIndex: UInt32
    let name: String
    let type: String
    let domain: String
}

struct DNSServiceResolveEvent: Equatable {
    let hostTarget: String
    let port: Int
}

struct DNSServiceAddressEvent: Equatable {
    let isAdded: Bool
    let address: String
}

/// A live DNS-SD operation; `cancel()` deallocates its `DNSServiceRef`.
protocol DNSServiceOperation: AnyObject {
    func cancel()
}

/// The dns_sd calls the discovery engine needs. Handlers run on the client's queue,
/// and operations must be started and cancelled on that queue too.
protocol DNSServiceClientProtocol: AnyObject {
    func register(
        name: String,
        type: String,
        domain: String,
        port: UInt16,
        handler: @escaping (DNSServiceRegisterEvent) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError>

    func browse(
        type: String,
        domain: String,
        handler: @escaping (Result<DNSServiceBrowseEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError>

    func resolve(
        name: String,
        type: String,
        domain: String,
        interfaceIndex: UInt32,
        handler: @escaping (Result<DNSServiceResolveEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError>

    func lookupIPv4(
        hostname: String,
        interfaceIndex: UInt32,
        handler: @escaping (Result<DNSServiceAddressEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError>
}

final class DNSServiceClient: DNSServiceClientProtocol {

    private let queue: DispatchQueue

    init(queue: DispatchQueue) {
        self.queue = queue
    }

    func register(
        name: String,
        type: String,
        domain: String,
        port: UInt16,
        handler: @escaping (DNSServiceRegisterEvent) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        let operation = DNSServiceRefOperation(handler: handler)
        var ref: DNSServiceRef?
        let error = DNSServiceRegister(
            &ref,
            DNSServiceFlags(kDNSServiceFlagsNoAutoRename),
            0,
            name,
            type,
            domain,
            nil,
            port.bigEndian,
            0,
            nil,
            { _, flags, errorCode, name, _, _, context in
                guard let operation = DNSServiceRefOperation<DNSServiceRegisterEvent>.from(context) else { return }
                if errorCode != DNSServiceErrorCode.noError {
                    operation.handler(.failed(DNSServiceError(code: errorCode)))
                } else if flags & DNSServiceFlags(kDNSServiceFlagsAdd) != 0 {
                    operation.handler(.registered(name: name.map { String(cString: $0) } ?? ""))
                } else {
                    operation.handler(.withdrawn)
                }
            },
            operation.context
        )
        return operation.attach(ref: ref, error: error, queue: queue)
    }

    func browse(
        type: String,
        domain: String,
        handler: @escaping (Result<DNSServiceBrowseEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        let operation = DNSServiceRefOperation(handler: handler)
        var ref: DNSServiceRef?
        let error = DNSServiceBrowse(
            &ref,
            0,
            0,
            type,
            domain,
            { _, flags, interfaceIndex, errorCode, serviceName, regtype, replyDomain, context in
                guard let operation = DNSServiceRefOperation<Result<DNSServiceBrowseEvent, DNSServiceError>>.from(context) else { return }
                guard errorCode == DNSServiceErrorCode.noError else {
                    operation.handler(.failure(DNSServiceError(code: errorCode)))
                    return
                }
                operation.handler(.success(DNSServiceBrowseEvent(
                    isAdded: flags & DNSServiceFlags(kDNSServiceFlagsAdd) != 0,
                    interfaceIndex: interfaceIndex,
                    name: serviceName.map { String(cString: $0) } ?? "",
                    type: regtype.map { String(cString: $0) } ?? "",
                    domain: replyDomain.map { String(cString: $0) } ?? ""
                )))
            },
            operation.context
        )
        return operation.attach(ref: ref, error: error, queue: queue)
    }

    func resolve(
        name: String,
        type: String,
        domain: String,
        interfaceIndex: UInt32,
        handler: @escaping (Result<DNSServiceResolveEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        let operation = DNSServiceRefOperation(handler: handler)
        var ref: DNSServiceRef?
        let error = DNSServiceResolve(
            &ref,
            0,
            interfaceIndex,
            name,
            type,
            domain,
            { _, _, _, errorCode, _, hosttarget, port, _, _, context in
                guard let operation = DNSServiceRefOperation<Result<DNSServiceResolveEvent, DNSServiceError>>.from(context) else { return }
                guard errorCode == DNSServiceErrorCode.noError else {
                    operation.handler(.failure(DNSServiceError(code: errorCode)))
                    return
                }
                operation.handler(.success(DNSServiceResolveEvent(
                    hostTarget: hosttarget.map { String(cString: $0) } ?? "",
                    port: Int(UInt16(bigEndian: port))
                )))
            },
            operation.context
        )
        return operation.attach(ref: ref, error: error, queue: queue)
    }

    func lookupIPv4(
        hostname: String,
        interfaceIndex: UInt32,
        handler: @escaping (Result<DNSServiceAddressEvent, DNSServiceError>) -> Void
    ) -> Result<any DNSServiceOperation, DNSServiceError> {
        let operation = DNSServiceRefOperation(handler: handler)
        var ref: DNSServiceRef?
        let error = DNSServiceGetAddrInfo(
            &ref,
            0,
            interfaceIndex,
            DNSServiceProtocol(kDNSServiceProtocol_IPv4),
            hostname,
            { _, flags, _, errorCode, _, address, _, context in
                guard let operation = DNSServiceRefOperation<Result<DNSServiceAddressEvent, DNSServiceError>>.from(context) else { return }
                guard errorCode == DNSServiceErrorCode.noError else {
                    operation.handler(.failure(DNSServiceError(code: errorCode)))
                    return
                }
                guard let ipv4 = address.flatMap(ipv4String) else { return }
                operation.handler(.success(DNSServiceAddressEvent(
                    isAdded: flags & DNSServiceFlags(kDNSServiceFlagsAdd) != 0,
                    address: ipv4
                )))
            },
            operation.context
        )
        return operation.attach(ref: ref, error: error, queue: queue)
    }
}

private func ipv4String(_ address: UnsafePointer<sockaddr>) -> String? {
    guard address.pointee.sa_family == sa_family_t(AF_INET) else { return nil }
    let inAddress = address.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
    // s_addr is in network byte order, so its bytes are the octets in order.
    return withUnsafeBytes(of: inAddress.s_addr) { bytes in
        bytes.map { String($0) }.joined(separator: ".")
    }
}

/// Owns one `DNSServiceRef` and the handler its C callback forwards to. The callback finds the
/// operation through an unretained context pointer, so the ref is deallocated before the operation dies.
private final class DNSServiceRefOperation<Event>: DNSServiceOperation {

    let handler: (Event) -> Void
    private var ref: DNSServiceRef?

    init(handler: @escaping (Event) -> Void) {
        self.handler = handler
    }

    deinit {
        cancel()
    }

    var context: UnsafeMutableRawPointer {
        Unmanaged.passUnretained(self).toOpaque()
    }

    static func from(_ context: UnsafeMutableRawPointer?) -> DNSServiceRefOperation<Event>? {
        guard let context else { return nil }
        return Unmanaged<DNSServiceRefOperation<Event>>.fromOpaque(context).takeUnretainedValue()
    }

    func attach(ref: DNSServiceRef?, error: DNSServiceErrorType, queue: DispatchQueue) -> Result<any DNSServiceOperation, DNSServiceError> {
        guard error == DNSServiceErrorCode.noError, let ref else {
            return .failure(DNSServiceError(code: error))
        }
        let queueError = DNSServiceSetDispatchQueue(ref, queue)
        guard queueError == DNSServiceErrorCode.noError else {
            DNSServiceRefDeallocate(ref)
            return .failure(DNSServiceError(code: queueError))
        }
        self.ref = ref
        return .success(self)
    }

    func cancel() {
        guard let ref else { return }
        self.ref = nil
        DNSServiceRefDeallocate(ref)
    }
}
