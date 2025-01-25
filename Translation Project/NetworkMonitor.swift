//
//  NetworkMonitor.swift
//  Translation Project
//
//  Created by Ali on 12/29/24.
//


import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private var monitor: NWPathMonitor?
    private var queue = DispatchQueue.global()

    private init() {}

    func startMonitoring() {
        monitor = NWPathMonitor()
        monitor?.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to the internet")
            } else {
                print("No internet connection")
            }
        }
        monitor?.start(queue: queue)
    }

    func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }

    func isConnected() -> Bool {
        guard let monitor = monitor else { return false }
        return monitor.currentPath.status == .satisfied
    }
}
