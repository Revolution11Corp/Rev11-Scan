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

  var selectedImage: UIImage?
  let defaults = UserDefaults(suiteName: Keys.suiteName)

  override func viewDidLoad() {
    self.placeholder = "Tap POST to send your CSV File\nto Rev11Scan.\n\nThen open the Rev11Scan\napp to view your beacons."
  }

  override func isContentValid() -> Bool {
      return true
    }

  override func didSelectPost() {

    clearSpreadsheetCache()

    if let content = extensionContext!.inputItems[0] as? NSExtensionItem {

      let contentType = kUTTypeCommaSeparatedText as String

      if let contents = content.attachments as? [NSItemProvider] {

        for attachment in contents {

          if attachment.hasItemConformingToTypeIdentifier(contentType) {
            attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in

              let url = data as! NSURL

              if let spreadsheetData = NSData(contentsOf: url as URL) {
                self.saveSpreadsheet(data: spreadsheetData)
              }
            }
          }
        }
      }
    }
      self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
  }

  func saveSpreadsheet(data: NSData) {
    defaults?.set(data, forKey: Keys.spreadsheetFile)
    defaults?.set(true, forKey: Keys.isNewSharedSpreadsheet)
  }

  func clearSpreadsheetCache() {
    defaults?.set(nil, forKey: Keys.spreadsheetFile)
  }
}
