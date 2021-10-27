//
//  MyTableViewCell.swift
//  swift_ble_test
//
//  Created by 정현석 on 2021/10/14.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet var lbDeviceName: UILabel!
    @IBOutlet var lbRSSI: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
