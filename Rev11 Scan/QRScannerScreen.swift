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
  var qrCodeFrameView: UIView?
  var scannedURL: String?

  let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeUPCECode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeAztecCode]


  override func viewDidLoad() {
    super.viewDidLoad()
    setupQRCaptureSession()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    setupQRFrameView()
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
      qrCodeFrameView?.frame = CGRectZero
      messageLabel.hidden = false
      messageLabel.text = "No QR code is detected"
      dismissViewControllerAnimated(true, completion: nil)
      return
    }

    let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

    if supportedBarCodes.contains(metadataObj.type) {

      let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj)
      qrCodeFrameView?.frame = barCodeObject!.bounds

      if metadataObj.stringValue != nil {
        scannedURL = metadataObj.stringValue
        //        showOptionsAlert(metadataObj.stringValue)
        //        print(metadataObj.stringValue)
        //        messageLabel.hidden = true
        messageLabel.text = scannedURL

        do {

          try CallbackURLKit.performAction("iBeconDemo", URLScheme: "fmp", parameters: ["url": scannedURL!], onSuccess: nil, onFailure: nil, onCancel: nil)


        } catch CallbackURLKitError.AppWithSchemeNotInstalled {
          print("FileMaker not installed or not implement x-callback-url in current os")

        } catch CallbackURLKitError.CallbackURLSchemeNotDefined {
          print("current app scheme not defined")

        } catch let e {
          print("exception \(e)")
        }
      }
    }
  }

  func showWebsite(foundURL: String) {
    let url = NSURL(string: foundURL)
    let vc = SFSafariViewController(URL: url!, entersReaderIfAvailable: true)
    qrCodeFrameView!.removeFromSuperview()
    presentViewController(vc, animated: true, completion: nil)
  }


  func showOptionsAlert(foundURL: String) {

    let alertController = UIAlertController(title: "QR Code Found", message: "Open in Safari?", preferredStyle: .Alert)
    let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action:UIAlertAction!) in
      self.showWebsite(foundURL)
    }

    let callbackAction = UIAlertAction(title: "Return to FileMaker", style: .Default) { (action:UIAlertAction!) in

    }

    alertController.addAction(yesAction)
    alertController.addAction(callbackAction)

    if presentedViewController == nil {
      self.presentViewController(alertController, animated: true, completion:nil)
    }
  }

  func setupQRFrameView() {

    qrCodeFrameView = UIView()

    if let qrCodeFrameView = qrCodeFrameView {
      qrCodeFrameView.layer.borderColor = UIColor.blueColor().CGColor
      qrCodeFrameView.layer.borderWidth = 4
      view.addSubview(qrCodeFrameView)
      view.bringSubviewToFront(qrCodeFrameView)
    }
  }
  
  
  
}

