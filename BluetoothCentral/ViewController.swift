//
//  ViewController.swift
//  BluetoothCentral
//
//  Created by Jelte Liekens on 06/08/16.
//  Copyright © 2016 Jelte Liekens. All rights reserved.
//

import Cocoa
import CoreBluetooth

let serviceUUID = CBUUID(string: "3A2D52EF-EF63-4B90-AF25-1D6BC2C14FAA")
let characteristicUUID = CBUUID(string: "7EA7A792-B0A9-4EF2-96AE-D2A1D516E140")

class ViewController: NSViewController {
    var manager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    @IBOutlet weak var myLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOn:
            print("Powered On")
            
            manager.scanForPeripherals(withServices: nil, options: nil)
            
        default:
            manager.stopScan()
            print("Powered Off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        let uuid = UUID(uuidString: "A226BBAB-6B7F-4E56-8E6D-599A66CC47EF")
        
        if peripheral.identifier == uuid {
            self.peripheral = peripheral
            manager.connect(peripheral, options: nil)
            manager.stopScan();
            print("Stop Scan")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name!)")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let index = peripheral.services?.index(where: { (service) -> Bool in service.uuid == serviceUUID }), let myService = peripheral.services?[index] {
            print("Discovered service: \(myService.uuid)")
            peripheral.discoverCharacteristics([characteristicUUID], for: myService)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: NSError?) {
        if let index = service.characteristics?.index(where: { $0.uuid == characteristicUUID }), let myChar = service.characteristics?[index] {
            print("Discovered characteristic: \(myChar.uuid)")
            
//            peripheral.readValue(for: myChar)
            peripheral.setNotifyValue(true, for: myChar)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: NSError?) {
        if let value = characteristic.value, let helloWorld = String(data: value, encoding: String.Encoding.utf8) {
            myLabel.stringValue = helloWorld
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: NSError?) {
        guard error == nil else {
            print("Did update notification with error: \(error?.localizedDescription)")
            return
        }
    }
}
