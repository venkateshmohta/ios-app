//
//  BlobUrlFileDownloadUtil.swift
//  WebToNative
//
//  Created by Akash Kamati on 26/10/23.
//  Copyright © 2023 WebToNative. All rights reserved.
//

import Foundation
import UIKit
import WebToNativeCore


/**
 A utility class for handling Blob URL file downloads and conversions.

 The `BlobUrlFileDownloadUtil` class provides methods for extracting filename and MIME type from a Blob URL, converting Blob URL data to base64 string, and saving base64 data as a file.

 */
class BlobUrlFileDownloadUtil{
    
    /// The shared instance of `BlobUrlFileDownloadUtil`.
    public static let shared = BlobUrlFileDownloadUtil()
    
    public var sharingText: String?
    public var shareFileAfterDownload = true
    public var openFileAfterDownload = false
    /// The MIME type of the file. Default is "application/octet-stream".
    public var fileMimeType = "application/octet-stream"
    
    
    private let openFileManager = FileManager()
    private let downloadManager = DownloadFileManager()
    
    func downloadBlobFile(url:String,fileName:String){
        let mimeType = getMimeType(from: fileName)
        fileMimeType = mimeType
        let js = getBlobDownloadJS(url: url, fileName: fileName)
        WebToNativeCore.webView.evaluateJavaScript(js)
    }
        
    /**
     Extracts the base64 string from a Blob URL.

     - Parameters:
        - blobUrl: The Blob URL from which to extract the base64 string.

     - Returns: The base64 string extracted from the Blob URL.
     */
    func getBase64StringFromBlobUrl(blobUrl: String) -> String {
        let data = extractFilenameAndMIMEType(from: blobUrl)
        fileMimeType = data["mimetype"]!
        let fileName = data["filename"]!
        let url = data["url"]!
        return getBlobDownloadJS(url: url, fileName: fileName)
    }
    
    private func getBlobDownloadJS(url:String,fileName:String) -> String{
        if url.hasPrefix("blob") {
            return """
                javascript: var xhr = new XMLHttpRequest();
                xhr.open('GET', '\(url)', true);
                xhr.setRequestHeader('Content-type','\(fileMimeType);charset=UTF-8')
                xhr.responseType = 'blob';
                xhr.onload = function(e) {
                    if (this.status == 200) {
                        var blobFile = this.response;
                        var reader = new FileReader();
                        reader.readAsDataURL(blobFile);
                        reader.onloadend = function() {
                        base64data = reader.result.toString();
                        console.log(base64data)
                        
                        window.webkit.messageHandlers.webToNativeInterface.postMessage({
                                action: "downloadBlob",
                                data: base64data,
                                filename:"\(fileName)"
                          });
                        }
                    }
                };
                xhr.send();
                """
        }
        return "javascript: console.log('It is not a Blob URL');"
    }
    
    /**
       Converts base64 data to a file and stores it locally.

       - Parameters:
          - base64Data: The base64 data to convert and store.
          - fileName: The name of the file to be saved.

       - Throws: An error if the file cannot be saved.
       */
    func convertBase64StringToFileAndStoreIt(_ base64Data: String, actualFileName: String) throws {

        var fileName = actualFileName
        let prefix = "data:\(fileMimeType);base64,"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var fileURL: URL? = nil
        let appConfig = WebToNativeConfig.sharedConfig

        if appConfig?.DOWNLOAD_MANAGER?.data?.enable ?? false{
            // Create a custom folder
            let customFolderURL = documentsDirectory.appendingPathComponent("Downloads")
            
            // Check if the folder exists, if not, create it
            if !FileManager.default.fileExists(atPath: customFolderURL.path) {
                do {
                    try FileManager.default.createDirectory(at: customFolderURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Error creating folder: \(error)")
                    return
                }
            }

            (fileURL, fileName) = downloadManager.getUniqueFileName(fileName: fileName, directory: customFolderURL)

            var fileMetadata = DownloadFileData(fileName: nil, time: nil)
            fileMetadata.fileName = fileName
            // Get current time
            let currentTime = Date()
            // Create file metadata object
            fileMetadata.time = currentTime
            // Save metadata (you can save it as per your storage mechanism)
            downloadManager.saveFileMetadata(fileMetadata)


        }
        else {
            (fileURL, fileName) = downloadManager.getUniqueFileName(fileName: fileName, directory: documentsDirectory)
        }
        if fileURL == nil {return}
        
        if base64Data.hasPrefix(prefix), let data = Data(base64Encoded: base64Data.replacingOccurrences(of: prefix, with: ""), options: .ignoreUnknownCharacters) {
            do {
                try data.write(to: fileURL!)
                print("File saved as: \(fileURL!.absoluteString)")
                if openFileAfterDownload {
                    OpenFileManager().openFile(from: UIViewController(), filePath: fileURL!)
                }
               
                // Show share dialog after download
                if shareFileAfterDownload {
                    let activityItems = [fileURL as Any, sharingText as Any] as [Any]
                    let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    
                    // Set the source view and source rect
                    if let viewController = WebToNativeCore.viewController {
                        activityViewController.popoverPresentationController?.sourceView = viewController.view
                        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0) // Center of the view
                        activityViewController.popoverPresentationController?.permittedArrowDirections = [] // No arrow
                    }
                    WebToNativeCore.viewController.present(activityViewController, animated: true, completion: nil)
                }
                else {
                    Toast.show(message: "File Downloaded", controller: WebToNativeCore.viewController)
                }
                shareFileAfterDownload = true
                openFileAfterDownload = false
            } catch {
                print("Failed to save the file: \(error)")
            }
        } else {
            print("Failed to extract valid Base64 data.")
        }
        sharingText = nil
    }
    
    func downloadDataUrlFile(from urlString: String, calledByShare: Bool = false) {
        guard
            let queryIndex = urlString.firstIndex(of: "?")
        else {
            print("Invalid blob URL: \(urlString)")
            return
        }
        
        let params = fetchQueryParamsFromUrl(url: urlString)
        let fileName = params["filename"] ?? "file-\(Int(Date().timeIntervalSince1970)).bin"
        let fileUrl = String(urlString[..<queryIndex])

        do {
            let mimeType = getMimeType(from: fileName)
            if calledByShare {
                shareFileUsingData(base64Data: fileUrl, mimeType: mimeType)
                
            }else {
                fileMimeType = mimeType
                BlobUrlFileDownloadUtil.shared.shareFileAfterDownload = Bool(params["shareFileAfterDownload"] ?? "true") ?? true
                try convertBase64StringToFileAndStoreIt(
                    fileUrl,
                    actualFileName: fileName
                )
            }
            print("Filename blob successfully downloaded")
        } catch {
            print("File download failed: \(error)")
        }
    }
    
    func shareFileUsingData(base64Data: String, mimeType: String){
        let prefix = "data:\(mimeType);base64,"
        
        if base64Data.hasPrefix(prefix), let data = Data(base64Encoded: base64Data.replacingOccurrences(of: prefix, with: ""), options: .ignoreUnknownCharacters) {
               
            // Show share dialog after download
                let activityItems =  [data as Any, sharingText as Any] as [Any]
                let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                
                // Set the source view and source rect
                if let viewController = WebToNativeCore.viewController {
                    activityViewController.popoverPresentationController?.sourceView = viewController.view
                    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0) // Center of the view
                    activityViewController.popoverPresentationController?.permittedArrowDirections = [] // No arrow
                }
                WebToNativeCore.viewController.present(activityViewController, animated: true, completion: nil)
                        
        } else {
            print("Failed to extract valid Base64 data.")
        }
    }
    
    /**
     Extracts filename and MIME type from a Blob URL.

     - Parameters:
        - urlString: The Blob URL from which to extract filename and MIME type.

     - Returns: A dictionary containing filename, MIME type, and URL information.
     */
    func extractFilenameAndMIMEType(from urlString: String) -> [String: String] {
        var result: [String: String] = [:]
        
        if let queryStartIndex = urlString.firstIndex(of: "?") {
            let queryString = urlString[queryStartIndex..<urlString.endIndex]
            
            if let filename = queryString.split(separator: "=").last {
                let filenameString = String(filename)
                
                // Calculate MIME type based on the file extension
                if let fileExtension = filenameString.split(separator: ".").last {
                    result["filename"] = filenameString
                    result["mimetype"] = getMimeType(from: filenameString)
                }
            }
        } else {
            // No query parameters, use default values
            result["filename"] = "file-\(Int(Date().timeIntervalSince1970)).bin"
            result["mimetype"] = "application/octet-stream"
        }
        
        // Extract the URL without the query string
        if let queryStartIndex = urlString.firstIndex(of: "?") {
            let urlWithoutQuery = String(urlString.prefix(upTo: queryStartIndex))
            result["url"] = urlWithoutQuery
        } else {
            result["url"] = urlString
        }
        
        return result
    }
    
    
    /// Returns the MIME type for a given file name based on its extension.
    ///
    /// This function analyzes the file name to determine its extension and returns
    /// the corresponding MIME type as a `String`. If the file extension is not recognized,
    /// the function defaults to "application/octet-stream".
    ///
    /// - Parameter fileName: The name of the file, including its extension.
    /// - Returns: A `String` representing the MIME type associated with the file extension.
    ///
    /// - Note: Supported extensions include "txt", "pdf", "jpg", "jpeg",  "png", etc.
    private func getMimeType(from fileName:String) -> String{
        
        let mimeType: String
        
        // Calculate MIME type based on the file extension
        if let fileExtension = fileName.split(separator: ".").last {
            let ext = String(fileExtension)
            switch ext {
                case "txt":
                    mimeType = "text/plain"
                case "pdf":
                    mimeType = "application/pdf"
                case "jpg", "jpeg":
                    mimeType = "image/jpeg"
                case "png":
                    mimeType = "image/png"
                case "mp3":
                    mimeType = "audio/mpeg"
                case "mp4":
                    mimeType = "video/mp4"
                    // Excel cases
                case "xlsx":
                    mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                case "xls":
                    mimeType = "application/vnd.ms-excel"
                case "xlsm":
                    mimeType = "application/vnd.ms-excel.sheet.macroEnabled.12"
                case "xlsb":
                    mimeType = "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
                case "csv":
                    mimeType = "text/csv"
                // Additional cases
                case "doc", "docx":
                    mimeType = "application/msword"
                case "ppt", "pptx":
                    mimeType = "application/vnd.ms-powerpoint"
                case "zip":
                    mimeType = "application/zip"
                case "json":
                    mimeType = "application/json"
                case "html":
                    mimeType = "text/html"
                // Add more cases for other file extensions as needed
                default:
                    mimeType = "application/octet-stream" // Default to binary data
                }
        }else{
            mimeType = "application/octet-stream"
        }
        return mimeType
    }
    
}
