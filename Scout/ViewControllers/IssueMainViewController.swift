//
//  IssueMainViewController.swift
//  Scout
//
//  Created by redphx on 4/7/16.
//  Copyright © 2016 Team Nato. All rights reserved.
//

import UIKit
import MapKit
class IssueMainViewController: UIViewController {
  
  
  @IBOutlet weak var mapView: MKMapView!
  let cllocationManager: CLLocationManager = CLLocationManager()
  let locationManager = CLLocationManager()
  let regionRadius: CLLocationDistance = 1000
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    
    centerMapOnLocation(initialLocation)
    
    
    //Request for location authorization
    //Request location authorization
    self.cllocationManager.requestAlwaysAuthorization()
    self.cllocationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      cllocationManager.desiredAccuracy = kCLLocationAccuracyBest
      cllocationManager.startUpdatingLocation()
    }
    // Do any additional setup after loading the view.
  }
  //Add Google Maps to the view
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(true)

  }
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius*2, regionRadius*2)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()
    }
  }

  @IBAction func onIssueFilterClicked(sender: AnyObject) {
    let issueFilterVC = IssueFilterViewController(nibName: "IssueFilterViewController", bundle: nil)
    presentViewController(issueFilterVC, animated: true, completion: nil)
  }
  
  @IBAction func onIssueListClicked(sender: AnyObject) {
    let issueListVC = IssueListViewController(nibName: "IssueListViewController", bundle: nil)
    presentViewController(issueListVC, animated: true, completion: nil)
    
  }
  
  @IBAction func onIssueDetailsClicked(sender: UIButton) {
    let issueDetailsVC = IssueDetailsViewController(nibName: "IssueDetailsViewController", bundle: nil)
    presentViewController(issueDetailsVC, animated: true, completion: nil)
  }
  
  
  @IBAction func onProfileClicked(sender: UIButton) {
    let profileHomeVC = ProfileHomeViewController(nibName: "ProfileHomeViewController", bundle: nil)
    presentViewController(profileHomeVC, animated: true, completion: nil)
  }
}
extension IssueMainViewController: CLLocationManagerDelegate {
}