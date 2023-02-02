//
//  WetherManager.swift
//  Clima
//
//  Created by USER on 14.10.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {  // create prtocol in the same class where we want to use protocol
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=991691196439e5473cad7c9f07587cde&units=metric"

    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeatherLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees ){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
        
    
    func performRequest(with urlString: String){
        //create URL
        if let url = URL(string: urlString){
            //Create URL session
            let session = URLSession(configuration: .default)
            //Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){ // validation because weather is optional because output WeatherModel? is optional
                        self.delegate?.didUpdateWeather(self, weather: weather)// self = WeatherManager
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData) // this method can throw error
            let id = decodedData.weather[0].id // weather[0] because in JSON format weather it is array consist of 1 item
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather // we have output of this function with type WeatherModel?
            
        } catch{ // if it does throw error 
            delegate?.didFailWithError(error: error) // error during parseJSON file
            return nil // if take an error we should have return nil because parseJSON has output WeatherModeel?
        }
    }
}
