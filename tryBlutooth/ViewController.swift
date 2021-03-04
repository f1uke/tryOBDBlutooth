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
    @IBOutlet weak var okBtn: UIButton!
    
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
//                                            self.sendInitCommand()
                                        })
        
    }
    
    @IBAction func okPressed(_ sender: Any) {
        sendInitCommand()
        
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
                                                }}}}}}}}}}}}
}
