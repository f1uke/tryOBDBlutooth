//
//  ObdBuletoothIO.swift
//  tryBlutooth
//
//  Created by Sattra on 3/2/21.
//

import CoreBluetooth

class ObdBluetoothIO: NSObject {
    let serviceUUID: String
    let obdCharacteristic: String
    let deviceName: String
    
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?
    var onResponse: ((String) -> ())?
    var onConnected: (() -> ())?
    
    var respData: String?
    
    init(serviceUUID: String, obdCharacteristic: String, deviceName: String, onConnected: (() -> ())? = nil, onResponse: ((String) -> ())? = nil ) {
        self.serviceUUID = serviceUUID
        self.obdCharacteristic = obdCharacteristic
        self.deviceName = deviceName
        self.onConnected = onConnected
        self.onResponse = onResponse
        
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func writeValue(value: String, onResponse: ((String) -> ())? = nil) {
        guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
            return
        }
        
        print("Sending.. =>\(value)")
        peripheral.writeValue(value.data(using: .utf8)!, for: characteristic, type: .withResponse)
        
        self.onResponse = onResponse
    }
    
}

extension ObdBluetoothIO: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([CBUUID(string: serviceUUID)])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == deviceName {
            connectedPeripheral = peripheral
            
            if let connectedPeripheral = connectedPeripheral {
                connectedPeripheral.delegate = self
                centralManager.connect(connectedPeripheral, options: nil)
            }
            centralManager.stopScan()
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
}

extension ObdBluetoothIO: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: obdCharacteristic)], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writableCharacteristic = characteristic
                
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
        onConnected?()
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            print(String(data: data, encoding:.utf8)!)
            if String(data: data, encoding: .utf8)?.suffix(2) == "\r>" {
                onResponse?(respData ?? "")
                respData = ""
            } else {
                respData = String(data: data, encoding:.utf8)!
            }
        }
        
    }
}
