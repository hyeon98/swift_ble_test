//
//  vcShowService.swift
//  swift_ble_test
//
//  Created by 정현석 on 2021/10/20.
//

import UIKit
import CoreBluetooth

class vcShowService: UIViewController {

    var dataReceived: String = ""

    var centralManager2: CBCentralManager!
    var receivedPeripheral: CBPeripheral!
    var devicePeripheral: CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(devicePeripheral ?? "Null")
        
        self.devicePeripheral = receivedPeripheral
        devicePeripheral.delegate = self
        
        centralManager2 = CBCentralManager(delegate: self, queue: nil)
    }
    
    @IBOutlet var lbTemp1: UILabel!
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension vcShowService: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {

        case .unknown:
            print("central.state is unknown")
        case .resetting:
            print("central.state is resetting")
        case .unsupported:
            print("central.state is unsupported")
        case .unauthorized:
            print("central.state is unauthorized")
        case .poweredOff:
            print("central.state is poweredOff")
        case .poweredOn:
            print("central.state is poweredOn")
            centralManager2.connect(devicePeripheral)
        @unknown default:
            print("central.state default case")
        }
    }

    private func centralManager2(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        devicePeripheral.discoverServices(nil)
    }
}

extension vcShowService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        guard let services = devicePeripheral.services else {return}
        for service in services {

            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        print("hyeon test3")
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {

            print(characteristic)
            // Body Location Characteristic
            if characteristic.properties.contains(.read) {

                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            // Heart Rate Measurement Characteristic
            if characteristic.properties.contains(.notify) {
                
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
}
