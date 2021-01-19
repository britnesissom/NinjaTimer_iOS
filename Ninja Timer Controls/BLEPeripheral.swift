//
//  ArduinoPeripheral.swift
//  Ninja Timer Controls
//
//  Created by Brit'ne Sissom on 6/2/20.
//  Copyright © 2020 Brit'ne Sissom. All rights reserved.
//

import CoreBluetooth

class BLEPeripheral: NSObject {

    private var buttonChar: CBCharacteristic?
    private var laserChar: CBCharacteristic?

    // might need to create separate characteristics for stop, reset, laser sensor
//    public static let serviceUUID = CBUUID.init(string: "0000dfb0-0000-1000-8000-00805f9b34fb")
//    public static let dataServiceUUID = CBUUID.init(string: "0000dfb1-0000-1000-8000-00805f9b34fb")
    
    public static let dataServiceUUID = CBUUID.init(string: "f0001130-0451-4000-b000-000000000000")
    public static let dataWriteCharUUID = CBUUID.init(string: "f0001131-0451-4000-b000-000000000000")
    
    override init() {
        super.init()
    }
    
    static func sendTimerAction(type: String) {

    }
    
    static func sendLaserSensor(enabled: Bool) {
    
    }
    
    func setButtonChar(char: CBCharacteristic) {
        self.buttonChar = char
    }
    
    func setLaserChar(char: CBCharacteristic) {
        self.laserChar = char
    }
    
    func getButtonChar() -> CBCharacteristic? {
        return self.buttonChar
    }
    
    func getLaserChar() -> CBCharacteristic? {
        return self.laserChar
    }
}
