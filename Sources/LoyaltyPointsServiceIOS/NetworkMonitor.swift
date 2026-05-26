import Foundation

public protocol NetworkMonitor: Sendable {
    var isOnline: Bool { get async }
}

public actor StaticNetworkMonitor: NetworkMonitor {
    private var online: Bool

    public init(isOnline: Bool = true) {
        self.online = isOnline
    }

    public var isOnline: Bool {
        online
    }

    public func setOnline(_ value: Bool) {
        online = value
    }
}
