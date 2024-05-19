//
//  MainExtension.swift
//  NFCTagSample
//
//  Created by Kanna on 19/05/24.
//

import Foundation
import UIKit
import CoreNFC

//MARK:- NFC Delegate
extension MainViewController {
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        print("Detected tags with \(messages.count) messages")
        
        //        session.invalidate()
    }
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if self.isWrite { // Write New Message to NFC
            // 1
            guard tags.count == 1 else {
                session.invalidate(errorMessage: "Cannot Write More Than One Tag in NFC")
                return
            }
            let currentTag = tags.first!
            
            // 2
            session.connect(to: currentTag) { error in
                
                guard error == nil else {
                    session.invalidate(errorMessage: "cound not connect to NFC card")
                    return
                }
                
                // 3
                currentTag.queryNDEFStatus { status, capacity, error in
                    
                    guard error == nil else {
                        session.invalidate(errorMessage: "Write error")
                        return
                    }
                    
                    switch status {
                    case .notSupported: session.invalidate(errorMessage: "")
                    case .readOnly:     session.invalidate(errorMessage: "")
                    case .readWrite:
                        
                        let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(
                            string: self.nfcMessage,
                            locale: Locale.init(identifier: "en")
                            
                        )!
                        
                        let uriPayloadFromURL = NFCNDEFPayload.wellKnownTypeURIPayload(
                            url: URL(string: "http://www.google.com")!
                        )!
                        
                        let messge = NFCNDEFMessage.init(
                            records: [
                                uriPayloadFromURL,
                                textPayload
                            ]
                        )
                        currentTag.writeNDEF(messge) { error in
                            
                            if error != nil {
                                session.invalidate(errorMessage: "Fail to write nfc card")
                            } else {
                                session.alertMessage = "Successfully writtern"
                                session.invalidate()
                            }
                        }
                        
                    @unknown default:   session.invalidate(errorMessage: "unknown error")
                    }
                }
            }
        }
        else {
            if tags.count > 1 {
                // Restart polling in 500ms
                let retryInterval = DispatchTimeInterval.milliseconds(500)
                session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
                DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                    session.restartPolling()
                })
                return
            }
            
            // Connect to the found tag and perform NDEF message reading
            let tag = tags.first!
            session.connect(to: tag, completionHandler: { (error: Error?) in
                if nil != error {
                    session.alertMessage = "Unable to connect to tag."
                    session.invalidate()
                    return
                }
                
                tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                    if .notSupported == ndefStatus {
                        session.alertMessage = "Tag is not NDEF compliant"
                        session.invalidate()
                        return
                    } else if nil != error {
                        session.alertMessage = "Unable to query NDEF status of tag"
                        session.invalidate()
                        return
                    }
                    
                    tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                        var statusMessage: String
                        if nil != error || nil == message {
                            statusMessage = "Fail to read NDEF from tag"
                        } else {
                            statusMessage = "Found 1 NDEF message"
                            DispatchQueue.main.async {
                                // Process detected NFCNDEFMessage objects.
                                
                                for record in message!.records
                                {
                                    DispatchQueue.main.async {
                                        switch record.typeNameFormat {
                                        case .nfcWellKnown:
                                            if let url = record.wellKnownTypeURIPayload() {
                                                self.lblNFCText?.text = url.absoluteString
                                            }
                                        case .absoluteURI:
                                            if let text = String(data: record.payload, encoding: .utf8) {
                                                self.lblNFCText?.text = text
                                            }
                                        case .media:
                                            if let type = String(data: record.type, encoding: .utf8) {
                                                self.lblNFCText?.text = type
                                            }
                                        case .nfcExternal, .empty, .unknown, .unchanged:
                                            fallthrough
                                        @unknown default:
                                            self.lblNFCText?.text = record.typeNameFormat.rawValue.description
                                        }
                                    }
                                }
                            }
                        }
                        
                        session.alertMessage = statusMessage
                        session.invalidate()
                    })
                })
            })
        }
    }
    
    func writeMessage() {
        DispatchQueue.main.async {
            guard NFCReaderSession.readingAvailable else {
                return
            }
            
            let session = NFCNDEFReaderSession(
                delegate: self,
                queue: nil,
                invalidateAfterFirstRead: false // set true if read mode
            )
            self.session = session
            self.session?.alertMessage = "Hold NFC card near iPhone"
            self.session?.begin()
        }
    }
    
    func readMessage() {
        DispatchQueue.main.async {
            guard NFCNDEFReaderSession.readingAvailable else {
                let alertController = UIAlertController(
                    title: "Scanning Not Supported",
                    message: "This device doesn't support tag scanning.",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            
            self.session = session
            self.session?.alertMessage = "Hold your iPhone near the item to learn more about it."
            self.session?.begin()
        }
    }
    
}

enum NFCMessage: String {
    case clockIn = "Clock In"
    case clockOut = "Clock Out"
    case takeBreak = "Take Break"
    case breakEnd = "Break End"
}

