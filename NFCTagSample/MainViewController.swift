//
//  MainViewController.swift
//  NFCTagSample
//
//  Created by Kanna on 16/05/24.
//

import UIKit
import CoreNFC

class MainViewController : UIViewController,NFCNDEFReaderSessionDelegate {
    
    //MARK:- Initialization
    @IBOutlet weak var lblNFCText: UILabel?
    var nfcMessage = ""
    var session: NFCNDEFReaderSession?
    var isWrite = true
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblNFCText?.text = ""
        // Do any additional setup after loading the view.
    }
    
    //MARK:- Button Action
    @IBAction func writeNFC(sender: UIButton) {
        isWrite = true
        self.lblNFCText?.text = ""
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
        
        self.writeMessage()
    }
    
    @IBAction func readNFC(sender: UIButton) {
        isWrite = false
        self.readMessage()
    }
}
