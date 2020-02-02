//
//  ViewController.swift
//  MapApp
//
//  Created by Suraj Narang on 1/12/20.
//  Copyright © 2020 Suraj Narang. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    var resultSearchController:UISearchController? = nil
    @IBOutlet weak var Map: MKMapView!
    let manager = CLLocationManager()
    var currentCordinate: CLLocationCoordinate2D?
    var annotation1: MKPointAnnotation = MKPointAnnotation()
    var x = 0
    var region1: MKCoordinateRegion?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
        createAlert(title: "ok", message: "okk")

    }
    
    func createAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func GetDirections() {
        let latitude: CLLocationDegrees = annotation1.coordinate.latitude 
        let longitude: CLLocationDegrees = annotation1.coordinate.longitude 
              
        let regionDistance:CLLocationDistance = 30
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),MKLaunchOptionsMapSpanKey:NSValue(mkCoordinateSpan: regionSpan.span)]
        
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Nearest Gas Station"
        mapItem.openInMaps(launchOptions: options)



    }

        
    

    func configureLocationServices(){
        manager.delegate = self
        //print ("hi")
        let status = CLLocationManager.authorizationStatus()
        
        if (status == .notDetermined) {
            manager.requestWhenInUseAuthorization()
        }
         
        else if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            Map.showsUserLocation = true
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.startUpdatingLocation()
        }
    }
    
    func zoomToLatestLocation (with coordinate: CLLocationCoordinate2D){
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        region1 = region
        Map.setRegion(region, animated: true)
                
        
        let request1 = MKLocalSearch.Request()
        request1.naturalLanguageQuery = "Gas Station"
        request1.region = region
        
        let search = MKLocalSearch(request: request1)

        search.start { (responce, error) in
            guard let responce = responce else { return}
            
            for item in responce.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.Map.addAnnotation(annotation)
                if (self.x == 0){
                    self.annotation1 = annotation
                    self.x = 1
                }
            }
            
          self.GetDirections()
        }
    }
}
    
    extension ViewController: CLLocationManagerDelegate {
      
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                print("did get latest location")
            guard let latestLocation = locations.first
                else {
                    return
            }
          
            if (currentCordinate == nil) {
                zoomToLatestLocation(with: latestLocation.coordinate)
            }
            currentCordinate = latestLocation.coordinate
               }
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if (status == .authorizedAlways || status == .authorizedWhenInUse) {
                Map.showsUserLocation = true
                manager.desiredAccuracy = kCLLocationAccuracyBest
                manager.startUpdatingLocation()
            }

        }
       
    }



