//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Octavio Cedeno on 2/24/17.
//  Copyright © 2017 Cedeno Enterprises, Inc. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class FlickrClient: NSObject, NSFetchedResultsControllerDelegate
{
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var stack: CoreDataStack!

    func getMethodParameters(latitude: Double, longitude: Double) -> [String: String]
    {
        
        return
        [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.SearchMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.BoundingBox: MapViewController.sharedInstance().bboxString(latitude: latitude, longitude: longitude),
            FlickrConstants.FlickrParameterKeys.SafeSearch: FlickrConstants.FlickrParameterValues.UseSafeSearch,
            FlickrConstants.FlickrParameterKeys.Extras: FlickrConstants.FlickrParameterValues.MediumURL,
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback
        ]
    }
    
    func getImages(_ methodParameters: [String: AnyObject], withPageNumber: Int, annotation: Annotations)
    {
        //Adding Page to Method's Parameters
        var methodParametersWithPageNumber = methodParameters
        methodParametersWithPageNumber[FlickrConstants.FlickrParameterKeys.Page] = withPageNumber as AnyObject
        
        //Create Session and Request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(parameters: methodParametersWithPageNumber))
        
        //Create a Network Request
        let task = session.dataTask(with: request)
        { (data, response, error) in
            
            guard (error == nil) else
            {
                print("Your request returned an error. Error: \(error)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else
            {
                print("Your request returned a status code other than 2xx!. Response: \(response)")
                return
            }
            
            guard let _ = data else {
                print("No data was returend by the request.")
                return
            }
            
            let parsedResults: [String: AnyObject]!
            
            do
            {
                parsedResults = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
            } catch
            {
                print("Could not parse the data as JSON. Data: \(data)")
                return
            }
            
            //Check if Flickr returned an error.
            guard let stat = parsedResults[FlickrConstants.FlickrResponseKeys.Status] as? String, stat == FlickrConstants.FlickrResponseValues.OKStatus else
            {
                print("Flickr API returned an error. See error code and message in \(parsedResults)")
                return
            }
            
            //Check if 'photos' key is in results.
            guard let photosDictionary = parsedResults[FlickrConstants.FlickrResponseKeys.Photos] as? [String: AnyObject] else
            {
                print("Cannot find key '\(FlickrConstants.FlickrResponseKeys.Photos)' in \(parsedResults)")
                return
            }
            
            //Check if Photo key is in dictionary.
            guard let photosArray = photosDictionary[FlickrConstants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else
            {
                print("Cannot find key '\(FlickrConstants.FlickrResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            
            //Create an Array of Medium URLs from JSON Return
            for i in photosArray
            {
                let mURL = i["url_m"] as! String
                self.stack = self.delegate.stack
                let newPhoto = Photo(imageData: mURL, context: self.stack.context)
                annotation.addToPhoto(newPhoto)
            }
        }
        
        //Start the task.
        task.resume()
    }
    
    //Helper for Creating a URL from Parameters
    private func flickrURLFromParameters(parameters: [String: AnyObject]) -> URL
    {
        var components = URLComponents()
        components.scheme = FlickrConstants.Flickr.APIScheme
        components.host = FlickrConstants.Flickr.APIHost
        components.path = FlickrConstants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key,value) in parameters
        {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

