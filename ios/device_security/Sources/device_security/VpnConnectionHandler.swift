import Flutter
import Network
import Foundation

class VpnConnectionHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "VpnMonitorQueue")
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        // Push initial state immediately
        DispatchQueue.main.async {
            events(self.checkVpnStatus())
        }
        
        // Listen to all network path changes
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let isVpn = self.checkVpnStatus()
            DispatchQueue.main.async {
                self.eventSink?(isVpn)
            }
        }
        monitor.start(queue: queue)
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        monitor.cancel()
        eventSink = nil
        return nil
    }
    
    private func checkVpnStatus() -> Bool {
        guard let dict = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any],
              let scopes = dict["__SCOPED__"] as? [String: Any] else {
            return false
        }
        
        for key in scopes.keys {
            let lowerKey = key.lowercased()
            if lowerKey.contains("tap") || 
               lowerKey.contains("tun") || 
               lowerKey.contains("ppp") || 
               lowerKey.contains("ipsec") || 
               lowerKey.contains("utun") {
                return true
            }
        }
        return false
    }
}
