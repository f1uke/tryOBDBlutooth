//
//  ViewController.swift
//  tryBlutooth
//
//  Created by Sattra on 2/26/21.
//

import UIKit
import CoreBluetooth
import Alamofire
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var okBtn: UIButton!
    
    private var locations: [MKPointAnnotation] = []
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    var updateTimer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    let obdServiceCBUUID = CBUUID(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")
    let obdCharacteristicCBUUID = CBUUID(string: "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F")
    var centralManager: CBCentralManager!
    var obdPeripheral: CBPeripheral!
    var obdBluetoothIO: ObdBluetoothIO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        obdBluetoothIO = ObdBluetoothIO(serviceUUID: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2", obdCharacteristic: "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F", deviceName: "IOS-Vlink",
                                        onConnected: {
                                            self.sendInitCommand()
                                        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func okPressed(_ sender: Any) {
//        sendInitCommand()
        locationManager.startUpdatingLocation()
    }
    @IBAction func Pressed0100(_ sender: Any) {
        obdBluetoothIO.writeValue(value: "0100\r\n") { (resp) in
            print("ViewController Resp = \(resp)")
        }
    }
    @IBAction func Pressed010C(_ sender: Any) {
        obdBluetoothIO.writeValue(value: "010C\r\n") { (resp) in
            print("ViewController Resp = \(resp)")
        }
    }
    
    func sendInitCommand() {
        obdBluetoothIO.writeValue(value: "ATZ\r\n") { (resp) in
            print("ViewController Resp = \(resp)")
            self.obdBluetoothIO.writeValue(value: "ATE0\r\n") { (resp) in
                print("ViewController Resp = \(resp)")
                self.obdBluetoothIO.writeValue(value: "ATL0\r\n") { (resp) in
                    print("ViewController Resp = \(resp)")
                    self.obdBluetoothIO.writeValue(value: "ATS1\r\n") { (resp) in
                        print("ViewController Resp = \(resp)")
                        self.obdBluetoothIO.writeValue(value: "ATAT0\r\n") { (resp) in
                            print("ViewController Resp = \(resp)")
                            self.obdBluetoothIO.writeValue(value: "ATSP0\r\n") { (resp) in
                                print("ViewController Resp = \(resp)")
                                self.obdBluetoothIO.writeValue(value: "ATH1\r\n") { (resp) in
                                    print("ViewController Resp = \(resp)")
                                    self.obdBluetoothIO.writeValue(value: "0100\r\n") { (resp) in
                                        print("ViewController Resp = \(resp)")
                                        self.obdBluetoothIO.writeValue(value: "0120\r\n") { (resp) in
                                            print("ViewController Resp = \(resp)")
                                            self.obdBluetoothIO.writeValue(value: "0140\r\n") { (resp) in
                                                print("ViewController Resp = \(resp)")
                                                self.obdBluetoothIO.writeValue(value: "ATH0\r\n") { (resp) in
                                                    print("ViewController Resp = \(resp)")
                                                    
                                                    self.updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                                                                            selector: #selector(self.call101C), userInfo: nil, repeats: true)
                                                    // register background task
                                                    self.registerBackgroundTask()
                                                    
                                                }}}}}}}}}}}}
    
    @objc func call101C() {
        obdBluetoothIO.writeValue(value: "010C\r\n") { (resp) in
            print("ViewController Resp = \(resp)")
        }
        
        AF.request("https://httpbin.org/get").response { response in
            print(response)
        }
    }
    
    @objc func reinstateBackgroundTask() {
        if updateTimer != nil && backgroundTask == .invalid {
            registerBackgroundTask()
        }
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != .invalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        
        // Add another annotation to the map.
        let annotation = MKPointAnnotation()
        annotation.coordinate = mostRecentLocation.coordinate
        
        // Also add to our map so we can remove old values later
        self.locations.append(annotation)
        
        // Remove values if the array is too big
//        while locations.count > 100 {
            let annotationToRemove = self.locations.first!
            self.locations.remove(at: 0)
            
            // Also remove from the map
//            mapView.removeAnnotation(annotationToRemove)
//        }
        
        if UIApplication.shared.applicationState == .active {
//            mapView.showAnnotations(self.locations, animated: true)
            print("New location is %@", mostRecentLocation)
        } else {
            print("App is backgrounded. New location is %@", mostRecentLocation)
        }
    }
    
}
