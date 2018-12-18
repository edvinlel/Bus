//
//  ViewController.swift
//  Bus
//
//  Created by Edvin Lellhame on 12/17/18.
//  Copyright © 2018 Edvin Lellhame. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlacePicker

/*
 
 A little description of What I was able to do in the short time I worked on this code test.
 
 ***** The User Interface
 -  I wanted to implement a beautiful design to the project as I strongly believe that design is one of the most important things.
    Taxi applications, Uber, Lyft, etc.. have all followed a design of just a mapView and a rounded corner uiview on the bottom center. This
    is the design I decided to go with as well.
 
 -  I also used a custom map interface given by Google. I decided to go with a light gray color for the map and also burgundy boxes for each bus stop(which you can see when
    you zoom deep in the current location and destination markers. You can find that custom implementation given
    by Google in the "style.json" file.
 
 -  I also wanted to implement an animation once the user selects the "Destination" textField
    The animation will scroll up the destination view with the keyboard popping up.
    The table view that you see with the San Francisco, CA was supposed to be a Google Places API search. i.e.
    When the user begins to type S A, the table view will start to populate with cities or places like
    San Francisco, San Diego, Santa Clara, etc..
 
 -  When the user taps return(or cancel, not yet implemented) the destination view will scroll back down to it's previous position with a brand new
    bus route(unless chosen cancel) given by the fastest and best bus route from Google Destination API
 
 
 ***** API/Frameworks
 -  Unfortunately I was not able to figure out how to use the Google Transit API or the 511 API in the short time I had. I have never worked with an
    API that was structured in that way.
 
 -  What I was able to do was use the Google Directions API in which I could make an HTTP Request using my API Key and some optional calls like transit_mode
    and the bus route.
 
 -  Core Location is what I used to grab the user's location. As of now, not knowing if you will be testing this in the simulator or on a real device, the option
    will not actually grab your location because I have hard coded Apple Park as the user's location and Google HQ as the destination(destination can be changed though)
 
 -  I decided to go with Google Maps instead of Apple Maps due to the custom look that I could achieve with Google Maps
 
 */


class ViewController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    
    // MARK: Properties
    let destinationView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 0.3
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowRadius = 15.0
        view.layer.shadowOpacity = 0.4
        
        return view
    }()
    
    let fromLabel: UILabel = {
        let label = UILabel()
        label.text = "From"
        label.font = UIFont(name: "Avenir", size: 16)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(red: 164/255.0, green: 176/255.0, blue: 190/255.0, alpha: 1)
        return label
    }()
    
    let fromImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "current_location_oval")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let toDestinationLabel: UILabel = {
        let label = UILabel()
        label.text = "To"
        label.font = UIFont(name: "Avenir", size: 16)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor(red: 164/255.0, green: 176/255.0, blue: 190/255.0, alpha: 1)
        return label
    }()
    
    let toImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Oval")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let currentLocationTextField: UITextField = {
        let textField = UITextField()
        textField.text = "Current Location"
        textField.font = UIFont(name: "Avenir", size: 18)
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        textField.borderStyle = .none
        textField.isUserInteractionEnabled = true
        
        return textField
    }()
    
    let fromTextFieldUnderlineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 223/255.0, green: 228/255.0, blue: 234/255.0, alpha: 1)
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 0.3
        
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowColor = UIColor(red: 223/255.0, green: 228/255.0, blue: 234/255.0, alpha: 1).cgColor
        view.layer.shadowOffset = CGSize(width: 11, height: 1)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 1
        view.layer.masksToBounds = false
        return view
    }()
    
    let toLocationTextField: UITextField = {
        let textField = UITextField()
        textField.text = "Destination"
        textField.textColor = UIColor(red: 164/255.0, green: 176/255.0, blue: 190/255.0, alpha: 1)
        textField.font = UIFont(name: "Avenir", size: 18)
        textField.font = UIFont.boldSystemFont(ofSize: 18)
        textField.borderStyle = .none
        textField.isUserInteractionEnabled = true
        return textField
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.estimatedRowHeight = 100
        
        return tv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.setImage(UIImage(named: "close"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: Variable(s)
    private let locationManager = CLLocationManager()
    private var mapView: GMSMapView?
    private var isKeyboardShown = false
    private let cellId = "cellId"
    private let placesClient = GMSPlacesClient()
    private var direction = ""
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupMapView()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        tableView.register(PlacesCell.self, forCellReuseIdentifier: cellId)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        currentLocationTextField.delegate = self
        toLocationTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        toLocationTextField.addGestureRecognizer(tapGesture)
        currentLocationTextField.addGestureRecognizer(tapGesture)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeUp.direction = .up
        destinationView.addGestureRecognizer(swipeUp)
        swipeUp.delegate = self
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeDown.direction = .down
        destinationView.addGestureRecognizer(swipeDown)
        swipeDown.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupViewsAndContstraints()
        for i in (self.mapView?.gestureRecognizers)! {
            self.mapView?.removeGestureRecognizer(i)
        }
    }
    
    
    
    // MARK: Method(s)
    private func setupMapView() {
        // Set up and initialize the Google MapView
        let alanLatitude = 37.2982535
        let alanLongitude = -121.8677811
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), camera: GMSCameraPosition.camera(withLatitude: alanLatitude, longitude: alanLongitude, zoom: 15.0))
        
        
        
        guard let googleMapView = mapView else { return }
        view.addSubview(googleMapView)
        
        
        do {
            // Add custom made style Google MapView to the view
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                googleMapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print(error)
        }
        
        loadMapView(withURL: "https://maps.googleapis.com/maps/api/directions/json?origin=Apple+Park&destination=Adobe+Inc&mode=transit&transit_mode=bus&key=\(Constants.googleMapsAPIKey)")
        
    }
    
    
    
    private func loadMapView(withURL url: String) {
        
        let request = URLRequest(url: URL(string:url)!)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    
                    // Parse the data and get the coordinates(latitude, longitude) of the route, from the start location to the end location of the best route
                    // given to us by the Google Directions API
                    let object = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                    
                    let routes = object?["routes"] as! [NSDictionary]
                    
                    var coordinates = [CLLocationCoordinate2D]()
                    
                    var legs = [[String: Any]]()
                    for route in routes {
                        legs = (route["legs"] as? [[String: Any]])!
                    }
                    
                    var steps = [[String: Any]]()
                    var startLocation = CLLocationCoordinate2D()
                    var endLocation = CLLocationCoordinate2D()
                    for i in legs {
                        steps = i["steps"] as! [[String: Any]]
                        guard let startLoc = i["start_location"] as? [String: Any] else { return }
                        guard let startLat = startLoc["lat"] as? Double else { return }
                        guard let startLon = startLoc["lng"] as? Double else { return }
                        startLocation = CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
                        
                        guard let endLoc = i["end_location"] as? [String: Any] else { return }
                        guard let endLat = endLoc["lat"] as? Double else { return }
                        guard let endLon = endLoc["lng"] as? Double else { return }
                        endLocation = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
                        
                    }
                    
                    for i in steps {
                        let location = i["start_location"] as? [String: Any]
                        guard let lat = location?["lat"] as? Double else { return }
                        guard let lon = location?["lng"] as? Double else { return }
                        
                        coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                    }
                    
                    let path = GMSMutablePath()
                    for i in coordinates {
                        path.addLatitude(i.latitude, longitude: i.longitude)
                        print(i)
                    }
                    
                    DispatchQueue.main.async {
                        // Create two points(Markers) on the map and add a polyline route to the two points
                        let polyline = GMSPolyline()
                        polyline.path = path
                        polyline.map = self.mapView
                        polyline.strokeColor = .black
                        polyline.strokeWidth = 2
                        
                        var markers = [GMSMarker]()
                        
                        let startMarker = self.createMarker(withTitle: "Apple Park", position: CLLocationCoordinate2D(latitude: startLocation.latitude, longitude: startLocation.longitude), icon: UIImage(named: "current_location_point")!)
                        startMarker.map = self.mapView
                        
                        let endMarker = self.createMarker(withTitle: "Adobe Inc.", position: CLLocationCoordinate2D(latitude: endLocation.latitude, longitude: endLocation.longitude), icon: UIImage(named: "map_point")!)
                        endMarker.map = self.mapView
                        
                        markers.append(startMarker)
                        markers.append(endMarker)
                        
                        var bounds = GMSCoordinateBounds()
                        for i in markers {
                            bounds = bounds.includingCoordinate(i.position)
                        }
                        let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
                        self.mapView?.animate(with: update)
                    }
                } catch  {
                    print(error.localizedDescription)
                }
                
            } else {
                print("Direction API error")
            }
            }.resume()
    }
    
    
    // ** Description: Create a marker of a point on the map
    // * title: Title shown when the marker is clicked.
    // * position: CLLocationCoordinate2D for the latitude and longitude position for the marker.
    // * icon: A UIImage for the marker being used.
    private func createMarker(withTitle title: String, position: CLLocationCoordinate2D, icon: UIImage) -> GMSMarker {
        let marker = GMSMarker()
        marker.title = title
        marker.icon = icon
        marker.position = position
        
        return marker
    }
    
    var cachedConstraints: [NSLayoutConstraint] = []
    // A private method used to add each of the UI views to the subviews along with their constraints
    private func setupViewsAndContstraints() {
        guard let googleMapView = mapView  else { return }
        
        googleMapView.addSubview(destinationView)
        googleMapView.addSubview(cancelButton)
        googleMapView.addSubview(fromLabel)
        googleMapView.addSubview(fromImageView)
        googleMapView.addSubview(currentLocationTextField)
        googleMapView.addSubview(fromTextFieldUnderlineView)
        googleMapView.addSubview(currentLocationTextField)
        googleMapView.addSubview(toImageView)
        googleMapView.addSubview(toDestinationLabel)
        googleMapView.addSubview(toLocationTextField)
        
        self.cachedConstraints = destinationView.anchor(top: nil, paddingTop: 0, leading: view.leadingAnchor, paddingLeading: 10, bottom: view.bottomAnchor, paddingBottom: 15, trailing: view.trailingAnchor, paddingTrailing: 10, width: 0, height: 150, withCached: self.cachedConstraints)
        
        cancelButton.anchor(top: destinationView.topAnchor, paddingTop: 15, leading: nil, paddingLeading: 0, bottom: nil, paddingBottom: 0, trailing: destinationView.trailingAnchor, paddingTrailing: 15, width: 10, height: 10)
        
        fromLabel.anchor(top: destinationView.topAnchor, paddingTop: 15, leading: destinationView.leadingAnchor, paddingLeading: 5, bottom: nil, paddingBottom: 0, trailing: nil, paddingTrailing: 0, width: 0, height: 0)
        
        fromImageView.anchor(top: fromLabel.bottomAnchor, paddingTop: 10, leading: destinationView.leadingAnchor, paddingLeading: 15, bottom: nil, paddingBottom: 0, trailing: nil, paddingTrailing: 0, width: 10, height: 10)
        
        currentLocationTextField.anchor(top: fromLabel.bottomAnchor, paddingTop: 4, leading: fromImageView.trailingAnchor, paddingLeading: 20, bottom: nil, paddingBottom: 0, trailing: destinationView.trailingAnchor, paddingTrailing: 2, width: 0, height: 0)
        
        fromTextFieldUnderlineView.anchor(top: currentLocationTextField.bottomAnchor, paddingTop: 15, leading: destinationView.leadingAnchor, paddingLeading: 0, bottom: nil, paddingBottom: 0, trailing: destinationView.trailingAnchor, paddingTrailing: 0, width: 0, height: 1)
        
        toDestinationLabel.anchor(top: currentLocationTextField.bottomAnchor, paddingTop: 25, leading: destinationView.leadingAnchor, paddingLeading: 5, bottom: nil, paddingBottom: 0, trailing: nil, paddingTrailing: 0, width: 0, height: 0)
        
        toImageView.anchor(top: toDestinationLabel.bottomAnchor, paddingTop: 10, leading: destinationView.leadingAnchor, paddingLeading: 15, bottom: nil, paddingBottom: 0, trailing: nil, paddingTrailing: 0, width: 10, height: 10)
        
        toLocationTextField.anchor(top: toDestinationLabel.bottomAnchor, paddingTop: 4, leading: toImageView.trailingAnchor, paddingLeading: 20, bottom: nil, paddingBottom: 0, trailing: destinationView.trailingAnchor, paddingTrailing: 2, width: 0, height: 0)
        
        tableView.anchor(top: toLocationTextField.bottomAnchor, paddingTop: 20, leading: destinationView.leadingAnchor, paddingLeading: 20, bottom: destinationView.bottomAnchor, paddingBottom: 0, trailing: destinationView.trailingAnchor, paddingTrailing: 20, width: 0, height: 0)
    }
    
    
    @objc private func handleTap() {
        animateView(isDirectionUp: true)
    }
    
    @objc private func closeButtonPressed() {
        animateView(isDirectionUp: false)
    }
    
    // Respond to the users swipe up or down of the destination view
    @objc private func respondToSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizer.Direction.down:
            animateView(isDirectionUp: false)
        case UISwipeGestureRecognizer.Direction.up:
            animateView(isDirectionUp: true)
        default:
            break
        }
    }
    
    // ** Description: Animate the view according to the direction of the user's swipe. The target calls the respondToSwipeGesture(gesture:) method which uses
    //                 a switch statement on the direction of the swipe and calls this method with the proper boolean value of the direction.
    // * isDirectionUp: Used to control the conditional statement by its boolean value: True - The swipe registered up; False - The swipe registered down
    private func animateView(isDirectionUp: Bool = true) {
        if isDirectionUp {
            UIView.animate(withDuration: 0.6, animations: {
                self.cancelButton.isHidden = false
                self.cachedConstraints = self.destinationView.anchor(top: self.view.topAnchor, paddingTop: 50, leading: self.view.leadingAnchor, paddingLeading: 10, bottom: self.view.bottomAnchor, paddingBottom: 0, trailing: self.view.trailingAnchor, paddingTrailing: 10, width: 0, height: 0, withCached: self.cachedConstraints)
                
                self.view.layoutIfNeeded()
            })
        } else {
            UIView.animate(withDuration: 0.6, animations: {
                self.cancelButton.isHidden = true
                self.cachedConstraints = self.destinationView.anchor(top: nil, paddingTop: 0, leading: self.view.leadingAnchor, paddingLeading: 10, bottom: self.view.bottomAnchor, paddingBottom: 15, trailing: self.view.trailingAnchor, paddingTrailing: 10, width: 0, height: 0, withCached: self.cachedConstraints)
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    
}

// MARK: TableView Delegate/DataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! PlacesCell
        cell.placeLabel.text = "San Francisco, CA"
        return cell
    }
}

// MARK: UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        animateView(isDirectionUp: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            textField.resignFirstResponder()
            animateView(isDirectionUp: false)
            textField.text = "Destination"
            return true
        } else {
            let string = textField.text
            let replacedString = string?.replacingOccurrences(of: " ", with: "+")
            guard let replaced = replacedString else { return true }
            direction = "https://maps.googleapis.com/maps/api/directions/json?origin=Apple+Park&destination=\(replaced)&mode=transit&transit_mode=bus&key=\(Constants.googleMapsAPIKey)"
            mapView?.clear()
            textField.resignFirstResponder()
            animateView(isDirectionUp: false)
            loadMapView(withURL: direction)
        }
        
        return true
    }
}


