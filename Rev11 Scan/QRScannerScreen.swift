//
//  QRScannerScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import SafariServices
import CallbackURLKit

class QRScannerScreen: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

  
  @IBOutlet weak var messageLabel: UILabel!

  var captureSession: AVCaptureSession?
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var scannedURL: String?

  let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]


  override func viewDidLoad() {
    super.viewDidLoad()
    setupQRCaptureSession()
    NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    messageLabel.hidden = false

    if (captureSession?.running == false) {
      captureSession!.startRunning()
    }
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    if (captureSession?.running == true) {
      captureSession!.stopRunning()
    }
  }

  func setupQRCaptureSession() {

    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    do {

      let input = try AVCaptureDeviceInput(device: captureDevice)

      captureSession = AVCaptureSession()
      captureSession?.addInput(input)

      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession?.addOutput(captureMetadataOutput)

      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
      captureMetadataOutput.metadataObjectTypes = supportedBarCodes

      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      view.layer.addSublayer(videoPreviewLayer!)

      captureSession?.startRunning()
      view.bringSubviewToFront(messageLabel)

    } catch {
      print(error)
      return
    }
  }

  func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {

    if metadataObjects == nil || metadataObjects.count == 0 {
      messageLabel.hidden = false
      messageLabel.text = "No QR code is detected"
      dismissViewControllerAnimated(true, completion: nil)
      return

    } else {

      let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

      if self.supportedBarCodes.contains(metadataObj.type) {

        if metadataObj.stringValue != nil {

          scannedURL = metadataObj.stringValue
          messageLabel.text = scannedURL!

          if URLParameter.sharedInstance.isFromFileMaker == true {

            let urlStringFromSourceApp = URLParameter.sharedInstance.baseURL!
            let decodedURLString = (urlStringFromSourceApp.stringByReplacingOccurrencesOfString("%26", withString: "&")) as String
            let builtURL = "\(decodedURLString)\(scannedURL!)"

            if let url = NSURL(string: builtURL) {
              dispatch_async(dispatch_get_main_queue(), {
                UIApplication.sharedApplication().openURL(url)
              })
            }

          } else {
            let url = NSURL(string: scannedURL!)
            UIApplication.sharedApplication().openURL(url!)
          }
        }
      }
    }
  }

  func showWebsite(foundURL: String) {
    let url = NSURL(string: foundURL)
    let vc = SFSafariViewController(URL: url!, entersReaderIfAvailable: true)
    presentViewController(vc, animated: true, completion: nil)
  }

}

