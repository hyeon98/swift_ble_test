//
//  ViewController.swift
//  swift_ble_test
//
//  Created by 정현석 on 2021/10/13.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralDelegate {

    @IBOutlet var myTableView: UITableView!
    // Cell의 Label에 표시할 내용
    var strArrayDeviceName = [String]()
    var strArrayDeviceRSSI = [String]()
    var intArrayDeviceRSSI = [Int]()
    
    let timeSelector: Selector = #selector(ViewController.timer01)
    var trigScan = false
    var countScan = 0
    
    var centralManager: CBCentralManager!
    var searchPeripheral = [CBPeripheral?]()
    var devicePeripheral: CBPeripheral!
    
    var countTableRow = 0
    
    @IBOutlet var btnSearch: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 대리자 위임
        myTableView.delegate = self
        myTableView.dataSource = self
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: timeSelector, userInfo: nil, repeats: true)
        
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        if trigScan == false {
            centralManager = CBCentralManager(delegate: self, queue: nil)
            countScan = 10
            trigScan = true
            countTableRow = 0
            strArrayDeviceName = []
            strArrayDeviceRSSI = []
            intArrayDeviceRSSI = []
            btnSearch.setTitle("Stop", for: .normal)
        }
        else {
            countScan = 0
        }
    }
    
    @objc func timer01()
    {
        if(trigScan == true)
        {
            if(countScan == 0)
            {
                centralManager.stopScan()
                trigScan = false
                
                btnSearch.setTitle("Search", for: .normal)
            }
            else
            {
                print("hyeon test2")
                centralManager.scanForPeripherals(withServices: nil)
                countScan -= 1
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

    /// 필수 함수 구현
    // 한 섹션(구분)에 몇 개의 셀을 표시할지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countTableRow // 한 개의 섹션당 10개의 셀을 표시하겠다
    }
    
    // 특정 row에 표시할 cell 리턴
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 내가 정의한 Cell 만들기
        let cell: MyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as! MyTableViewCell
        // Cell Label의 내용 지정
//        if strArrayDeviceName.count != 0 {
        cell.lbDeviceName.text = strArrayDeviceName[indexPath.row]
        cell.lbRSSI.text = strArrayDeviceRSSI[indexPath.row]
//        }
        
        // 생성한 Cell 리턴
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vcShowService = self.storyboard?.instantiateViewController(withIdentifier: "vcShowService") as! vcShowService
        vcShowService.modalPresentationStyle = .fullScreen
        vcShowService.modalTransitionStyle = .coverVertical
        vcShowService.dataReceived = "TEST"
        
        self.devicePeripheral = searchPeripheral[indexPath.row]
        devicePeripheral.delegate = self
        vcShowService.receivedPeripheral = devicePeripheral

        self.present(vcShowService, animated: true, completion: nil)
        
        countScan = 0
        
//        self.devicePeripheral = searchPeripheral[indexPath.row]
//        devicePeripheral.delegate = self
//        centralManager.connect(devicePeripheral)
                
        switch indexPath.row {
        case 0:
            print("case0")
        case 1:
            print("case1")
        case 2:
            print("case2")
        default:
            print("default")
        }
    }
}

extension ViewController: CBCentralManagerDelegate {

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
        @unknown default:
            print("central.state default case")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard peripheral.name != nil else {return}
        
        let tempSearchName = peripheral.name ?? "Null"
        var tempStrDeviceRSSI = String(Int(truncating: RSSI))
        var tempIntDeviceRSSI = Int(truncating: RSSI)
        if tempIntDeviceRSSI == 127 {
            tempIntDeviceRSSI = -99
            tempStrDeviceRSSI = "-99"
        }
        
        if let firstIndex = strArrayDeviceName.firstIndex(of: tempSearchName) {
            
            strArrayDeviceName[firstIndex] = tempSearchName
            strArrayDeviceRSSI[firstIndex] = tempStrDeviceRSSI
            intArrayDeviceRSSI[firstIndex] = tempIntDeviceRSSI
            searchPeripheral[firstIndex] = peripheral
        }
        else
        {
            strArrayDeviceName.append(tempSearchName)
            strArrayDeviceRSSI.append(tempStrDeviceRSSI)
            intArrayDeviceRSSI.append(tempIntDeviceRSSI)
            searchPeripheral.append(peripheral)
            
            countTableRow += 1
        }
        
        //오름차순 정렬
        for stand in 0..<(intArrayDeviceRSSI.count - 1) { //스캔 작업 반복
            var maxIndex = stand
            for index in (stand + 1)..<intArrayDeviceRSSI.count { //스캔 작업 (stand가 0이면 1번 index부터 마지막 Index까지 돌며 최소값을 찾아야 하니까)
                if intArrayDeviceRSSI[index] > intArrayDeviceRSSI[maxIndex] {
                    maxIndex = index
                }
            }
            intArrayDeviceRSSI.swapAt(stand, maxIndex) //숫자형 배열 자리 바꿈
            
            strArrayDeviceName.swapAt(stand, maxIndex) //위 계산 기반 문자열 이름 자리바꿈
            strArrayDeviceRSSI.swapAt(stand, maxIndex) //위 계산 기반 문자열 감도 자리바꿈
            searchPeripheral.swapAt(stand, maxIndex)
        }
        
        self.myTableView.reloadData()
        
        if countTableRow == 10 {
            centralManager.stopScan()
            trigScan = false
            
            btnSearch.setTitle("Search", for: .normal)
        }
    }
}

