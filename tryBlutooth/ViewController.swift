//
//  ViewController.swift
//  tryBlutooth
//
//  Created by Sattra on 2/26/21.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    let obdServiceCBUUID = CBUUID(string: "E7810A71-73AE-499D-8C15-FAA9AEF0C3F2")
    let obdCharacteristicCBUUID = CBUUID(string: "BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F")
    var centralManager: CBCentralManager!
    var obdPeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
}

extension ViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is .unknown")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == "IOS-Vlink" {
            obdPeripheral = peripheral
            obdPeripheral.delegate = self
            print(obdPeripheral.name ?? "peripheral has no name")
            print(obdPeripheral.description)
            centralManager.stopScan()
            centralManager.connect(obdPeripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        obdPeripheral.discoverServices([obdServiceCBUUID])
        
    }
    
}

extension ViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            peripheral.discoverCharacteristics([obdCharacteristicCBUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let chars = service.characteristics else {
            return
        }
        guard chars.count > 0 else {
            return
        }
        let char = chars[0]
        peripheral.setNotifyValue(true, for: char)
        peripheral.discoverDescriptors(for: char)
        
        print (char.properties)
        peripheral.writeValue("ATZ\r\n".data(using: .utf8)!, for: char, type: CBCharacteristicWriteType.withResponse)
        
        peripheral.readValue(for: char)
        if let value = char.value {
            print(String(data:value, encoding:.utf8) ?? "bad utf8 data")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            print(String(data:value, encoding:.utf8)!)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic.descriptors ?? "bad didDiscoverDescriptorsFor")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error)
        }
        print("wrote to \(characteristic)")
        if let value = characteristic.value {
            print(String(data:value, encoding:.utf8)!)
        }
    }
    
}
