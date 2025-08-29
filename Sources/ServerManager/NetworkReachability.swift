import Foundation
import Network

protocol NetworkReachabilityProtocol {
    var isNetworkAvailable: Bool { get }
    func checkConnectivity() -> Bool
}

final class NetworkReachability: NetworkReachabilityProtocol {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkReachability")
    private var isConnected = false
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
    
    private func stopMonitoring() {
        monitor.cancel()
    }
    
    var isNetworkAvailable: Bool {
        return isConnected
    }
    
    func checkConnectivity() -> Bool {
        return isConnected
    }
}
