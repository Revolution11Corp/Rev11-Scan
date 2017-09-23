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

class QRScannerScreen: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

  
  @IBOutlet weak var messageLabel: UILabel!

  var captureSession: AVCaptureSession?
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var scannedURL: String?

  let supportedBarCodes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.aztec]


  override func viewDidLoad() {
    super.viewDidLoad()
    setupQRCaptureSession()
    NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    messageLabel.isHidden = false

    if (captureSession?.isRunning == false) {
      captureSession!.startRunning()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    if (captureSession?.isRunning == true) {
      captureSession!.stopRunning()
    }
  }

  func setupQRCaptureSession() {

    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)

    do {

      let input = try AVCaptureDeviceInput(device: captureDevice!)

      captureSession = AVCaptureSession()
      captureSession?.addInput(input)

      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession?.addOutput(captureMetadataOutput)

      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = supportedBarCodes

      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      view.layer.addSublayer(videoPreviewLayer!)

      captureSession?.startRunning()
      view.bringSubview(toFront: messageLabel)

    } catch {
      print(error)
      return
    }
  }

  func metadataOutput(captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

    if metadataObjects == nil || metadataObjects.count == 0 {
      messageLabel.isHidden = false
      messageLabel.text = "No QR code is detected"
      dismiss(animated: true, completion: nil)
      return

    } else {

      let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

      if self.supportedBarCodes.contains(metadataObj.type) {

        if metadataObj.stringValue != nil {

          scannedURL = metadataObj.stringValue
          messageLabel.text = scannedURL!

          if URLParameter.sharedInstance.isFromFileMaker == true {

            let urlStringFromSourceApp = URLParameter.sharedInstance.baseURL!
            let decodedURLString = (urlStringFromSourceApp.replacingOccurrences(of: "%26", with: "&")) as String
            let builtURL = "\(decodedURLString)\(scannedURL!)"

            if let url = URL(string: builtURL) {
              DispatchQueue.main.async(execute: {
                UIApplication.shared.openURL(url)
              })
            }

          } else {
            let url = URL(string: scannedURL!)
            UIApplication.shared.openURL(url!)
          }
        }
      }
    }
  }

  func showWebsite(_ foundURL: String) {
    let url = URL(string: foundURL)
    let vc = SFSafariViewController(url: url!, entersReaderIfAvailable: true)
    present(vc, animated: true, completion: nil)
  }

}

