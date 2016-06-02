//
//  ViewController.swift
//  sfGrioPOIApp
//
//  Created by Korin Wong-Horiuchi on 6/1/16.
//  Copyright © 2016 Korin Wong-Horiuchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // holds the locations for multiple searches
    @IBOutlet weak var locationsTableView: UITableView!
    // input text fields
    @IBOutlet weak var longitudeText: UITextField!
    @IBOutlet weak var latitudeText: UITextField!
    // find button
    @IBOutlet weak var findButton: UIButton!
    
    //a dictionary with key: neighborhood name, value: array of CGPoint arrays representing regions of multipolygon
    var neighborhoods = [ String : [[CGPoint]] ]()
    //locations for storing
    var foundLocation = [ (String , CGPoint) ]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        latitudeText.adjustsFontSizeToFitWidth = true
        longitudeText.adjustsFontSizeToFitWidth = true
        
        //setup tableview
        locationsTableView.delegate = self
        locationsTableView.dataSource = self
        locationsTableView.backgroundColor = UIColor.darkGrayColor()
        locationsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        locationsTableView.backgroundColor = UIColor.blackColor()
        
        //read the SFNeighborhoods geojson file
        readFile("SFNeighborhoods")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Parse data file
    
    //read the file, get the data, and pass to parse function
    func readFile(nameOfFile : String)
    {
        let filePath = NSBundle.mainBundle().pathForResource(nameOfFile, ofType: "geojson")
        do {
            let data = try NSData(contentsOfFile: filePath!, options:NSDataReadingOptions.DataReadingMappedIfSafe)
            
            if let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            {
                parseNeighborhoods(jsonResult)
            }
        }
        catch {
            print("couldn't find data")
        }
    }
    
    //parse through the dictionary and sort into neighborhoods dictionary with name and regions
    func parseNeighborhoods (data : NSDictionary)
    {
        let features = data["features"]
        var neighborhoodName : String?
        
        if let feat = features
        {
            for i in 0..<feat.count
            {
                if let feature = feat[i]
                {
                    //get the "name" property of the neighborhood
                    if let featureProperties = feature["properties"]
                    {
                        if let name = featureProperties!["name"]
                        {
                            neighborhoodName = name as? String
                        }
                    }
                    
                    //initialize an array of CGPoints to hold the multiple polygons within the MultiPolygon object.
                    var regions = [[CGPoint]]()
                    
                    //get the Geometry of the Neighborhood
                    if let geometry = feature["geometry"]
                    {
                        //cast coordinates array to a nested float array that represents the mutli polygon.
                        let coordinates = (geometry!["coordinates"] as! NSArray) as! [[[[Float]]]]
                        for polygon in coordinates
                        {
                            for region in polygon
                            {
                                //array of points that represent a region (1 polygon)
                                var arrayOfPoints = [CGPoint]()
                                for i in 0 ..< region.count
                                {
                                    let coordinate = region[i]
                                    let point = CGPointMake(CGFloat(coordinate[0]), CGFloat(coordinate[1]))
                                    arrayOfPoints.append(point)
                                }
                                regions.append(arrayOfPoints)
                            }
                        }
                    }
                    
                    //add the nested array of parsed CGPoint arrays to the neighborhoods dictionary
                    if regions.count > 0
                    {
                        if let name = neighborhoodName
                        {
                            neighborhoods[name] = regions
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Search for coordinates
    @IBAction func findButtonHit(sender: AnyObject)
    {
        //get the coordinates from the textfields and convert to float
        let lonFloat = (longitudeText.text! as NSString).floatValue
        let latFloat = (latitudeText.text! as NSString).floatValue
        //format into a CGPoint
        let pointsToCheck = CGPointMake(CGFloat(lonFloat), CGFloat(latFloat))
        
        //loop through the neighborhood's multipolygon and search for the coordinate.
        for (name, coord) in neighborhoods
        {
            for region in coord
            {
                //check if CGPoint is inside the polygon
                let insideNeighborhood = contains(region, point: pointsToCheck)
                
                if insideNeighborhood
                {
                    //update the tableview
                    foundLocation.append((name, pointsToCheck))
                    locationsTableView.reloadData()
                    //reset the textfields
                    longitudeText.text = ""
                    latitudeText.text = ""
                    return
                }
            }
        }
    }
    
    //We use UIBezierPath to create a polygon then check to see if it containsPoint
    func contains(polygon: [CGPoint], point: CGPoint) -> Bool {
        if polygon.count <= 1 {
            return false
        }
        
        let p = UIBezierPath()
        let firstPoint = polygon[0] as CGPoint
        
        p.moveToPoint(firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLineToPoint(polygon[index] as CGPoint)
        }
        
        p.closePath()
        
        return p.containsPoint(point)
    }
    
    //MARK: TableView delegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foundLocation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        //for each foundLocation create a cell with the location information
        let cell  = tableView.dequeueReusableCellWithIdentifier("cell")
        let cellInfo = foundLocation[indexPath.row]
        cell?.textLabel?.font = UIFont.systemFontOfSize(12)
        cell?.textLabel?.text = "\(cellInfo.0) - \(cellInfo.1)"
        //add a placeholder image
        cell?.imageView?.image = UIImage(named: "mission")
        cell?.backgroundColor = UIColor.lightGrayColor()
        return cell!
    }
    
    //create a header called Found Places
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 18))
        let label = UILabel(frame: CGRectMake(10, 5, tableView.frame.size.width, 18))
        label.font = UIFont.systemFontOfSize(14)
        label.text = "Found Places"
        view.addSubview(label)
        view.backgroundColor = UIColor.grayColor()
        
        return view
    }



}

