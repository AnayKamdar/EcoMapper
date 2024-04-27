//
//  EnvironmentalData.swift
//  EcoMapper
//
//  Created by Anay Kamdar on 3/18/24.
//
import Foundation


struct EnvironmentalData {
    var id: String = UUID().uuidString
    var temperature: Double?
    var humidity: Double?
    var timestamp: Date = Date()
}

struct WeatherObservation: Codable {
    let temperature: Double?
    let humidity: Double?
    
    enum CodingKeys: String, CodingKey {
        case temperature, humidity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let temperatureString = try container.decodeIfPresent(String.self, forKey: .temperature) {
            temperature = Double(temperatureString)
        } else {
            temperature = nil
        }
        
        humidity = try container.decodeIfPresent(Double.self, forKey: .humidity)
    }
}





struct WeatherResponse: Decodable {
    var firstObservation: WeatherObservation?
    
    enum CodingKeys: String, CodingKey {
        case weatherObservations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var observationsArray = try container.nestedUnkeyedContainer(forKey: .weatherObservations)
        if !observationsArray.isAtEnd {
            firstObservation = try observationsArray.decode(WeatherObservation.self)
        }
    }
}

extension WeatherResponse: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(firstObservation, forKey: .weatherObservations)
    }
}


struct Location{
    var latitude: Double
    var longitude : Double
    var time: Double
}
