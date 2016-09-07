//
//  ShareViewController.swift
//  Rev11Scan-ShareExtension
//
//  Created by Sean's Macboo Pro on 9/3/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

  let suiteName = "group.rev11scan"

  var selectedImage: UIImage?

  override func isContentValid() -> Bool {
      return true
    }

  override func didSelectPost() {

    // Make sure we have a valid extension item
    if let content = extensionContext!.inputItems[0] as? NSExtensionItem {

//      let contentType = kUTTypeImage as String
//      let contentType = kUTTypeSpreadsheet as String
      let contentType = kUTTypeCommaSeparatedText as String
      // A couple kUTTypes that might work... kUTTypeJSON, kUTTypeCommaSeparatedText, kUTTypeSpreadsheet, kUTTypeFileURL

      // Verify the provider is valid
      if let contents = content.attachments as? [NSItemProvider] {

        // look for images
        for attachment in contents {

          if attachment.hasItemConformingToTypeIdentifier(contentType) {
            attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in

              print("Data = \(data)")

              let url = data as! NSURL

              if let spreadsheetData = NSData(contentsOf: url as URL) {
                self.saveSpreadsheet(data: spreadsheetData)
              }
            }
          }
        }
      }
    }

      // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
      self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)


  }

// Need to convert "saveImage" to "saveFile" for .csv or .json.

  func saveSpreadsheet(data: NSData) {

    let prefs = UserDefaults(suiteName: suiteName)
    prefs?.set(data, forKey: "spreadsheetFileAsData")
    print("*** File As Data = \(prefs?.object(forKey: "spreadsheetFileAsData"))")
  }

  // Saves an image to user defaults.
//  func saveImage(color: String, imageData: NSData) {
//    if let prefs = UserDefaults(suiteName: suiteName) {
//      prefs.removeObject(forKey: color)
//      prefs.set(imageData, forKey: color)
//    }
//  }

}
