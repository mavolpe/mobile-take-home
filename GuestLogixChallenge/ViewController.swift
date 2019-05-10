//
//  ViewController.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-08.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var originButton: UIButton!
    @IBOutlet var destinationButton: UIButton!
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var searchResults: UITableView!
    @IBOutlet var waitIndicator: UIActivityIndicatorView!
    @IBOutlet var loadingMessage: UILabel!
    @IBOutlet var waitView: UIVisualEffectView!
    let routeFinder = RouteFinder()
    var airports:[Airport] = []
    var searchedAirports:[Airport] = []
    var origin = ""
    var destination = ""
    var pickingDestination = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchResults.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "searchTableViewCell")
   
        self.mapView.alpha = 0
        self.destinationButton.alpha = 0
        self.originButton.alpha = 0
        self.originButton.layer.borderColor = UIColor.blue.cgColor
        self.originButton.layer.borderWidth = 2
        self.originButton.layer.cornerRadius = 2
        
        self.destinationButton.layer.borderColor = UIColor.blue.cgColor
        self.destinationButton.layer.borderWidth = 2
        self.destinationButton.layer.cornerRadius = 2
        
        destinationButton.setTitleColor(UIColor.white, for: UIControl.State.selected)
        originButton.setTitleColor(UIColor.white, for: UIControl.State.selected)

        mapView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.waitViewTapped(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        waitView.addGestureRecognizer(tapGesture)

        showWaitView(show: true, message: NSLocalizedString("Loading airports, please wait...", comment: "Loading airports, please wait..."))
        
        AirportManager.sharedInstance.getAirports(completion: { (airports) in
            DispatchQueue.main.async { [weak self] in
                guard let this = self else{
                    return
                }
                
                this.showWaitView(show: false, message: "")
                this.airports = airports
                UIView.animate(withDuration: 0.5, animations: {
                    this.mapView.alpha = 1
                    this.destinationButton.alpha = 1
                    this.originButton.alpha = 1
                })
            }
        })
    }
    
    // MARK: dismiss the wait view if it was tapped
    @objc func waitViewTapped(gesture:UITapGestureRecognizer){
        showWaitView(show: false, message: "")
    }
    
    // MARK: show or hide the wait view with a message...
    func showWaitView(show:Bool, waitIndicator:Bool = true, message:String){
        self.waitIndicator.isHidden = !waitIndicator
        self.loadingMessage.text = message
        self.destinationButton.isUserInteractionEnabled = !show
        self.originButton.isUserInteractionEnabled = !show
        UIView.animate(withDuration: 0.2) {
            self.waitView.alpha = show ? 1 : 0
        }
    }
    
    // MARK: render flight hops on the screen
    func renderHops(hops:[HopViewModel]){
        
        var mapAnnotations:[MKPointAnnotation] = []

        var points:[CLLocationCoordinate2D] = []
        
        for (index,hop) in hops.enumerated(){

            let sourceLocation = CLLocationCoordinate2D(latitude: hop.originLatitude, longitude: hop.originLongitude)
            let destinationLocation = CLLocationCoordinate2D(latitude: hop.destLatitude, longitude: hop.destLongitude)
            
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            let sourceAnnotation = MKPointAnnotation()
            
            sourceAnnotation.title = String("(\(index+1)) - \(hop.originAirPortName)")
            
            if let location = sourcePlacemark.location {
                sourceAnnotation.coordinate = location.coordinate
            }
            
            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.title = String("(\(index+2)) - \(hop.destinationAirPortName)")
            
            if let location = destinationPlacemark.location {
                destinationAnnotation.coordinate = location.coordinate
            }
            
            mapAnnotations.append(sourceAnnotation)
            mapAnnotations.append(destinationAnnotation)
            
            points.append(contentsOf:[sourceLocation, destinationLocation])
        }
        
        self.mapView.showAnnotations(mapAnnotations, animated: true )
        let polyLine = MKPolyline(coordinates: points, count: points.count)
        self.mapView.addOverlay(polyLine)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    // MARK: Origin and destination selection routines
    @IBAction func selectOrigin(_ sender: Any) {
        pickingDestination = false
        searchBar.alpha = 1
        searchBar.text = ""
        searchBar.isHidden = false
        searchBar.showsCancelButton = true
        originButton.isSelected = true
        destinationButton.isSelected = false
        showWaitView(show: false, message: "")
    }
    
    @IBAction func selectDestination(_ sender: Any) {
        pickingDestination = true
        searchBar.alpha = 1
        searchBar.text = ""
        searchBar.isHidden = false
        searchBar.showsCancelButton = true
        destinationButton.isSelected = true
        originButton.isSelected = false
        showWaitView(show: false, message: "")
    }
    
    // MARK: kick off the actual route finding routine...
    private func findRoute(){
        guard origin.isEmpty == false && destination.isEmpty == false else{
            return
        }
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        showWaitView(show: true, message: NSLocalizedString("Searching for routes, please wait...", comment: "Searching for routes, please wait..."))
        
        routeFinder.findRoute(origin: origin, destination: destination) { [weak self] (possibleFlights) in
            guard let this = self else{
                return
            }
            if possibleFlights.count > 0{
                let flights = possibleFlights.map({$0.enumerated().compactMap({HopViewModel(route: $1, airports: this.airports, flightIndex: $0*2)})})
                
                let shortestTrip = TripDistanceCalculator.getShortestTrip(trips: flights)
                
                DispatchQueue.main.async { [weak self] in
                    guard let this = self else{
                        return
                    }
                    this.showWaitView(show: false, message: "")
                    this.renderHops(hops: shortestTrip)
                }
            }else{
                DispatchQueue.main.async {
                    this.showWaitView(show: true, waitIndicator: false, message: NSLocalizedString("Sorry there were no routes found", comment: "Sorry there were no routes found"))
                    
                    this.originButton.isUserInteractionEnabled = true
                    this.destinationButton.isUserInteractionEnabled = true
                    Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: { (timer) in
                        this.showWaitView(show: false, message: "")
                    })
                }
            }
        }
    }
}

// MARK: TableView delegates and search functionality
extension ViewController : UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedAirports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchTableViewCell") as? SearchTableViewCell{
            cell.airport = searchedAirports[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clearSearch()
        let buttonTitle = String("\(searchedAirports[indexPath.row].IATA) - \(searchedAirports[indexPath.row].name) - \(searchedAirports[indexPath.row].city)")
        if pickingDestination {
            destinationButton.setTitle(buttonTitle, for: UIControl.State.normal)
            destination = searchedAirports[indexPath.row].IATA
        }else{
            originButton.setTitle(buttonTitle, for: UIControl.State.normal)
            origin = searchedAirports[indexPath.row].IATA
        }
        
        if origin.isEmpty == false && destination.isEmpty == false{
            findRoute()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchLower = searchText.lowercased()
    
        searchedAirports = airports.filter({$0.city.lowercased().contains(searchLower) ||
            $0.IATA.lowercased().contains(searchLower) ||
            $0.country.lowercased().contains(searchLower) ||
            $0.name.lowercased().contains(searchLower)
        })
        
        searchResults.reloadData()
        searchResults.isHidden = false
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        clearSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        clearSearch()
    }
    
    func clearSearch(){
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        searchResults.isHidden = true
        originButton.isSelected = false
        destinationButton.isSelected = false
    }
}
