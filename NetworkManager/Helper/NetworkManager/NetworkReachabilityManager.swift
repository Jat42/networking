//
//  NetworkReachabilityManager.swift
//  NetworkManager
//
//  Created by Jat42 on 26/07/21.
//

import Foundation
import Network

class NetworkRechability: NSObject {
    
    private static let monitor = NWPathMonitor()
    
    /// Set this property to true after app has been launched.
    /// After setting this property to true you can get globel closure notification for network changes.
    /// Set this property to false after app goes to background.
    static var startMonitoring: Bool = false {
        didSet {
            startMonitoring ? startMonitoringNetwork() : stopMonitoringNetwork()
        }
    }
    
    /// Use this property to check if device has access to internet connection
    static var isRechable: Bool {
        get {
            monitor.currentPath.status == .satisfied
        }
    }
    
    /// Use this property for checking that if device is connected to mobile data or not
    static var isExpensive: Bool {
        get {
            monitor.currentPath.isExpensive
        }
    }
    
    /// Use this property for checking current used interface type
    static var interfaceType: NWInterface.InterfaceType? {
        get {
            monitor.currentPath.availableInterfaces.filter { monitor.currentPath.usesInterfaceType($0.type) }.first?.type
        }
    }
    
    /// Use this property for checking the available network interface type
    static var availableInterfacesTypes: [NWInterface.InterfaceType] {
        get {
            monitor.currentPath.availableInterfaces.map { $0.type }
        }
    }
    
    /**
     Use this handler for getting live changes for network in view controller file
            
     - parameter Bool: If returns true than network is rechable and vice versa.

     */
    
    static var networkStatusHandler: ((Bool) -> Void)?
    
    
    private static func startMonitoringNetwork() {
        print("Start monitoring network")
        let queue = DispatchQueue(label: "NetworkRechability_Monitor")
        
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            
            if path.status == .satisfied {
                networkStatusHandler?(true)
            } else {
                networkStatusHandler?(false)
            }
        }
        
    }
    
    private static func stopMonitoringNetwork() {
        print("Stop monitoring network")
        monitor.cancel()
    }
    
    deinit {
        NetworkRechability.stopMonitoringNetwork()
    }
    
}
