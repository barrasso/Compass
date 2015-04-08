//
//  MBSwiftPostman.swift
//  Compass
//
//  Created by Mark on 2/27/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import Foundation

class MBSwiftPostman {
    
    // MARK: UserAE Indoor Search Functions
    
    func findQueriedUserLocBeacon(userid: String) {
        
    }
    
    func extractLocBeaconContent (userid: String) {
        
    }
    
    // MARK: UserAE Outdoor Search Functions
    
    func findQueriedUserLocGPS(userid: String) {
        
        let httpMethod = "GET"
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkUserAE/?from=http:52.10.62.166:10000&requestIdentifier=12345&resultContent=2"
        
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        
        let queue = NSOperationQueue()
        
        // create connection on new thread
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                println("Error: \(error)")
                println("Response: \(response)")
                
            } else {
                
                // deserialize json object
                let json = JSON(data: data)
                println("retrieved json object: \(json)")
                println("\n-------------------------------\n")
                
                // extract UserAE container list
                for obj in json["output"]["ResourceOutput"][0]["Attributes"][0] {
                    println(obj.1)
                    
                    // check for queried user id
                    var string: String = obj.1.stringValue
                    if string.rangeOfString(userid, options: nil, range: Range(start: string.startIndex, end: string.endIndex), locale: nil) != nil {
                        println("Found user: \(userid)")
                        self.extractLocGPSContent(userid)
                        
                    } else {
                        println("Did not find user.")
                    }
                }
                println("\n-------------------------------\n")
            }
        } // end NSURLConnection block
    }
    
    func extractLocGPSContent(userid: String) {
        
        let httpMethod = "GET"
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkUserAE/"+userid+"/latest?from=http:52.10.62.166:10000&requestIdentifier=12345&resultContent=2"
        
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        
        let queue = NSOperationQueue()
        
        // create connection on new thread
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if error != nil {
                println("Error: \(error)")
                println("Response: \(response)")
                
            } else {
                
                // deserialize json object
                let json = JSON(data: data)
                println("received user container: \(json)")
                println("\n-------------------------------\n")
                
                // extract gps location content
                
                
            }
        } // end NSURLConnection block
    }
    
    // MARK: UserAE POST Functions
    
    func createNewUserContainer() {
        
        // set input method
        let httpMethod = "POST"
        
        let userID = PFUser.currentUser().username
        
        // use this url to create new user ID
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkUserAE/?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        // default JSON payload
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"container",
            "content": [
                "labels":"",
                "resourceName":userID,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var responseError: NSError?
            // deserialize json object
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:&responseError)
            
            if responseError == nil {
                println("Successfully deserialized...\n")
                
                if json is NSDictionary {
                    let deserializedDictionary = json as NSDictionary
                    println("Deserialized JSON Dictionary = \(deserializedDictionary)")
                }
                else if json is NSArray {
                    let deserializedArray = json as NSArray
                    println("Deserialized JSON Array = \(deserializedArray)")
                } else {
                    println("Something other object was returned...")
                }
            } else if responseError != nil {
                println("An error happened while deserializing the JSON data: \(responseError)")
            }
        }
    }
    
    // MARK: LocationAE POST Functions
    
    func createContentInstanceWith(beaconID: String) {
        
        // set input method
        let httpMethod = "POST"
        
        // use this url to create contentInstance
        let urlAsString = "http://52.10.62.166:8282/InCSE1/MarkLocationAE/Things/MACAddrOfPhone/LocBeacon/BeaconID?from=http:52.10.62.166:10000&requestIdentifier=12345"
        
        /* use this json payload to create content instances */
        var params: [NSString : AnyObject] =
        [
            "from":"http:localhost:10000",
            "requestIdentifier":"12345",
            "resourceType":"contentInstance",
            "content": [
                "resourceName":"",
                "contentInfo":"ID1",
                "content":beaconID,
            ]
        ]
        
        // url request properties
        let url = NSURL(string: urlAsString)
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var err: NSError?
        
        // config request with timeout
        let urlRequest = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 15.0)
        urlRequest.HTTPMethod = httpMethod
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("Basic YWRtaW46YWRtaW4=", forHTTPHeaderField: "Authorization")
        urlRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
        // init queue
        let queue = NSOperationQueue()
        
        // create connection on a new thread for request
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue) { (reponse: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var responseError: NSError?
            // deserialize json object
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error:&responseError)
            
            if responseError == nil {
                println("Successfully deserialized...\n")
                
                if json is NSDictionary {
                    let deserializedDictionary = json as NSDictionary
                    println("Deserialized JSON Dictionary = \(deserializedDictionary)")
                }
                else if json is NSArray {
                    let deserializedArray = json as NSArray
                    println("Deserialized JSON Array = \(deserializedArray)")
                } else {
                    println("Something other object was returned...")
                }
            } else if responseError != nil {
                println("An error happened while deserializing the JSON data: \(responseError)")
            }
        }
    }
}
