//
//  EnviromentalViewModel.swift
//  EcoMapper
//
//  Created by Anay Kamdar on 3/18/24.
//

import Foundation
import CoreData

class EnvironmentalDataViewModel: ObservableObject {
    @Published var environmentalData = [EnvironmentalData]()

    let session = URLSession.shared
    let username = "akamdar" 
    
    
    func addData(userTemperature: Double, userHumidity: Double, latitude: Double, longitude: Double) {
        let context = PersistenceController.shared.container.viewContext

        fetchWeatherData(latitude: latitude, longitude: longitude) { apiTemperature, apiHumidity in
            DispatchQueue.main.async {
                context.performAndWait {
                    let newEntry = EEntity(context: context)
                    newEntry.apiTemperature = apiTemperature ?? 0.0
                    newEntry.apiHumidity = apiHumidity ?? 0.0
                    newEntry.latitude = latitude
                    newEntry.longitude = longitude
                    newEntry.userTemperature = userTemperature
                    newEntry.userHumidity = userHumidity
                    do {
                        try context.save()
                    } catch {
                        // Handle the error appropriately
                        print("Failed to save data: \(error.localizedDescription)")
                    }
                    
                    print(newEntry)
                }
            }
        }
    }


    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Double?, Double?) -> Void) {
        let urlBuilder = WeatherURLBuilder(username: username)
        guard let url = urlBuilder.buildWeatherURL(latitude: latitude, longitude: longitude) else {
            print("Invalid URL for the weather service.")
            completion(nil, nil)
            return
        }
    
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather data: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let data = data else {
                print("No data returned from weather service.")
                completion(nil, nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                if let observation = weatherResponse.firstObservation {
                    completion(observation.temperature, observation.humidity)
                } else {
                    print("Weather data could not be found in the response.")
                    completion(nil, nil)
                }
            } catch {
                print("Error parsing weather data: \(error)")
                completion(nil, nil)
            }
        }.resume()
    }
}

struct WeatherURLBuilder {
    private let username: String

    init(username: String) {
        self.username = username
    }

    func buildWeatherURL(latitude: Double, longitude: Double) -> URL? {
        let offset = 10.0
        let north = latitude + offset
        let south = latitude - offset
        let east = longitude + offset
        let west = longitude - offset

        return URL(string: "http://api.geonames.org/weatherJSON?formatted=true&north=\(north)&south=\(south)&east=\(east)&west=\(west)&username=\(username)")
    }
}
