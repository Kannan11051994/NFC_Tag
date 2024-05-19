//
//  MainViewController.swift
//  NFCTagSample
//
//  Created by Kanna on 16/05/24.
//

import UIKit

class MainViewController : UIViewController {

    @IBOutlet weak var lblNFCText: UILabel?
    var nfcMessage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func writeNFC(sender: UIButton) {
        
        switch sender.tag {
        case 0:
            nfcMessage = NFCMessage.clockIn.rawValue
            break
        case 1:
            nfcMessage = NFCMessage.clockOut.rawValue
            break
        case 2:
            nfcMessage = NFCMessage.takeBreak.rawValue
            break
        case 3:
            nfcMessage = NFCMessage.breakEnd.rawValue
            break
        default:
            nfcMessage = ""
        }
    }
    
    
    @IBAction func readNFC(sender: UIButton) {
        
    }

}


enum NFCMessage: String {
    case clockIn = "Clock In"
    case clockOut = "Clock Out"
    case takeBreak = "Take Break"
    case breakEnd = "Break End"
}
