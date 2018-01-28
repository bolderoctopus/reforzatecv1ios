//
//  Downloader.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 12/28/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import Foundation

class Downloader {
    class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request =  URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
    
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if /*let tempLocalUrl = tempLocalUrl,*/ error == nil {
                // Success
                if let _ = (response as? HTTPURLResponse)?.statusCode {
                    //print("Success")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl!, to: localUrl)                    
                    completion()

                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }
//
            } else {
                print("Failure: %@", error!.localizedDescription);
            }
        }
        task.resume()
    }
}
