//
//  BLEControl.swift
//  Ninja Timer Controls
//
//  Created by Brit'ne Sissom on 6/2/20.
//  Copyright © 2020 Brit'ne Sissom. All rights reserved.
//

import CoreBluetooth

class BLEControl: NSObject, ObservableObject, CBPeripheralDelegate, CBCentralManagerDelegate {

    @Published var isEnabled = false
    @Published var isConnected = false
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var cc2640r2f: BLEPeripheral
    
    static let shared = BLEControl()

    
    override private init() {
        cc2640r2f = BLEPeripheral()
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    func writeValue(withValue value: Data) {
        // Check if it has the write property
        if cc2640r2f.getButtonChar()!.properties.contains(.write) && peripheral != nil {
            print("sending value ", value)
            peripheral.writeValue(value, for: cc2640r2f.getButtonChar()!, type: .withResponse)
            
        }
    }
    
    func connect() {
        if self.centralManager.state != .poweredOn {
            self.isConnected = false
            self.isEnabled = false
            print("Central is not powered on")
        } else {
            self.isEnabled = true
            print("Connect: central scanning for", BLEPeripheral.dataServiceUUID)
            centralManager.scanForPeripherals(withServices: [BLEPeripheral.dataServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central state update")
        if central.state != .poweredOn {
            self.isConnected = false
            self.isEnabled = false
            print("Central is not powered on")
        } else {
            self.isEnabled = true
            print("didUpdateState: central scanning for", BLEPeripheral.dataServiceUUID)
            centralManager.scanForPeripherals(withServices: [BLEPeripheral.dataServiceUUID],
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // Handles the result of the scan
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            print("name: \(name), uuid: ", peripheral.identifier.uuidString)
        } else {
            print("uuid: ", peripheral.identifier.uuidString)
        }

        print ("Advertisement Data : \(advertisementData)")
        // We've found it so stop scan
        self.centralManager.stopScan()

        // Copy the peripheral instance
        self.peripheral = peripheral
        self.peripheral.delegate = self

        // Connect!
        self.centralManager.connect(self.peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        if peripheral == self.peripheral {
            self.isConnected = true
            print("Connected to cc2640")
            peripheral.discoverServices([BLEPeripheral.dataServiceUUID])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == BLEPeripheral.dataServiceUUID {
                    print("service found")
                    //Now kick off discovery of characteristics
                    peripheral.discoverCharacteristics([BLEPeripheral.dataWriteCharUUID], for: service)
                    return
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            print(characteristics)
            for characteristic in characteristics {
                if characteristic.uuid == BLEPeripheral.dataWriteCharUUID {
                    print("blePeripheral write characteristic found")
                    cc2640r2f.setButtonChar(char: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("error: ", error.debugDescription)
        } else {
            print("value successfully written to cc2640")
        }
    }
    
     func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral == self.peripheral {
            print("Disconnected")
            self.peripheral = nil
            self.isConnected = false
            
            centralManager.scanForPeripherals(withServices: [BLEPeripheral.dataServiceUUID],
                                                  options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
     }
}
