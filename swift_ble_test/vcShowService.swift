//
//  vcShowService.swift
//  swift_ble_test
//
//  Created by 정현석 on 2021/10/20.
//

import UIKit
import CoreBluetooth

class vcShowService: UIViewController {

    //ble
    var dataReceived: String = ""
    var centralManager2: CBCentralManager!
    var receivedPeripheral: CBPeripheral!
    var devicePeripheral: CBPeripheral!
    var _characteristics: [CBCharacteristic]?
    var flagTemp1 = 0
    
    //table
    @IBOutlet var tbServices: UITableView!
    let serviceName: Array<String> = [ "service1", "service2", "service3" ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("init ble start")
        print(receivedPeripheral ?? "Null")
        centralManager2 = CBCentralManager(delegate: self, queue: nil)
        print("init ble complete")
        
        //table
//        tbServices.delegate = self
//        tbServices.dataSource = self
    }
    
    @IBOutlet var lbTemp1: UILabel!
    
    @IBAction func btnBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    @IBAction func btnTemp1(_ sender: Any) {
        if flagTemp1 == 0 {
            var parameter = NSInteger(0x31)
            let data = Data(bytes: &parameter, count: 1)
            
            if _characteristics!.count > 0 {
                print(_characteristics!)
                let characteristic = _characteristics![0]
                devicePeripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
            
            flagTemp1 = 1
        }
        else {
            var parameter = NSInteger(0x32)
            let data = Data(bytes: &parameter, count: 1)
            
            if _characteristics!.count > 0 {
                print(_characteristics!)
                let characteristic = _characteristics![0]
                devicePeripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
            
            flagTemp1 = 0
        }
    }
    
}

extension vcShowService: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempCell = tbServices.dequeueReusableCell(withIdentifier: "serviceName", for: indexPath) as! cellServices
        tempCell.lbServiceName.text = serviceName[indexPath.row]
        
        return tempCell
    }
    
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
            centralManager2.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state default case")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard peripheral.name != nil else {return}

        if peripheral.identifier == receivedPeripheral.identifier {
            print(peripheral)
            
            self.devicePeripheral = peripheral
            devicePeripheral.delegate = self
            centralManager2.connect(devicePeripheral)
            centralManager2.stopScan()
            
            print("connected-----------------------")
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("hyeon test1")
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

        guard let characteristics = service.characteristics else { return }
        _characteristics = service.characteristics
        
        for characteristic in characteristics {

            print(characteristic)
            // Body Location Characteristic
            if characteristic.properties.contains(.read) {

                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            
            if characteristic.properties.contains(.write) {
                
                print("\(characteristic.uuid): properties contains .write")
                var parameter = NSInteger(0x31)
                let data = Data(bytes: &parameter, count: 1)
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
            }
            
            // Heart Rate Measurement Characteristic
            if characteristic.properties.contains(.notify) {
                
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
}
