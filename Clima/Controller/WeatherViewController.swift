//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self // set current class as the delegate for the locationManager
        locationManager.requestWhenInUseAuthorization() // ask from user explicit permission
        locationManager.requestLocation() // trigger didUpdateLocations and didFailWithError method
        
        
        weatherManager.delegate = self // set current class as the delegate
        searchTextField.delegate = self // textField should report back to our view controller whats happening
    }
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate{
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // for "go" button on keyboard
        searchTextField.endEditing(true) // dismiss keyboard
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{ // validation what user typed
            return true
        } else {
            textField.placeholder = "Type something" // when the textField is empty and user try to press go button or searchPressed
            return false // do not trigger method textFieldDidEndEditing and keybord do not dismiss
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) { // this method trigger when user  stop editing
        
        if let city = searchTextField.text{
            weatherManager.fetchWeather(cityName: city)
        }
        searchTextField.text = "" // to clear text in textField after user press go ot serchPressed
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate{
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){ // weatherManager because it is trigger this method
        DispatchQueue.main.async{ //  to update user interface in the main thread because session task in WeatherManager maybe not finish yet and this allows  not frozen UIElements for users
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
 //MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate{ // to know weather in your location and get location update for request
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{ // to take last item in array [CLLocation]
            locationManager.stopUpdatingLocation() // we can repeatly activate this method from the button locationPressed
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeatherLocation(latitude: lat, longitude: lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
