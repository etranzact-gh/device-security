import Flutter
import UIKit

class UsbConnectionHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Push initial state immediately
        events(isPluggedIn())
        
        // Listen to battery state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
        eventSink = nil
        return nil
    }
    
    @objc private func batteryStateDidChange() {
        eventSink?(isPluggedIn())
    }
    
    private func isPluggedIn() -> Bool {
        let state = UIDevice.current.batteryState
        return state == .charging || state == .full
    }
}
