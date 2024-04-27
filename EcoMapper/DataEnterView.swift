//
//  DataEnterView.swift
//  EcoMapper
//
//  Created by Anay Kamdar on 3/18/24.
//

import SwiftUI
import MapKit

class LocationSearchService {
    func searchForLocation(using query: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Location not found."])))
                return
            }
            
            completion(.success(coordinate))
        }
    }
}

struct DataEnterView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var viewModel: EnvironmentalDataViewModel
    @State private var searchQuery = ""
    @State private var temperature: Double = 0.0
    @State private var humidity: Double = 0.0
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var pointsOfInterest: [PointOfInterest] = []

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search for a location", text: $searchQuery)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: search) {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .padding()

                Map(coordinateRegion: $region, annotationItems: pointsOfInterest) { point in
                    MapPin(coordinate: point.coordinate, tint: .blue)
                }
                .frame(height: 300)

                Form {
                    Slider(value: $temperature, in: 0...100, step: 0.1) {
                        Text("Temperature")
                    }
                    Text("Temperature: \(temperature, specifier: "%.1f")°C")

                    Slider(value: $humidity, in: 0...100, step: 0.1) {
                        Text("Humidity")
                    }
                    Text("Humidity: \(humidity, specifier: "%.1f")%")

                    Button("Submit") {
                        let currentCoordinate: CLLocationCoordinate2D
                        if let firstPoint = pointsOfInterest.first {
                            currentCoordinate = firstPoint.coordinate
                        } else {
                            currentCoordinate = CLLocationCoordinate2D(latitude: 34.052235, longitude: -118.243683)
                        }
                        viewModel.addData(
                            userTemperature: temperature,
                            userHumidity: humidity,
                            latitude: currentCoordinate.latitude,
                            longitude: currentCoordinate.longitude
                        )
                    }
                }
                .navigationTitle("Input Data")
            }
        }
    }
    func search() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchQuery
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Search failed: \(error.localizedDescription)")
                return
            }
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                print("No results found.")
                return
            }
            let newPoint = PointOfInterest(coordinate: coordinate)
            self.pointsOfInterest = [newPoint]

            self.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        }
    }
}

struct PointOfInterest: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct DataEnterView_Previews: PreviewProvider {
    static var previews: some View {
        DataEnterView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
