//
//  ContentView.swift
//  EcoMapper
//
//  Created by Anay Kamdar on 3/18/24.
//

import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EEntity.userTemperature, ascending: true)],
        animation: .default)
    private var items: FetchedResults<EEntity>

    @State private var showingHistory = false
    @State private var showingScatterPlot = false

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("EcoMapper")
                            .font(.largeTitle)
                            .foregroundColor(.primary)

                        Spacer()
                        
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .padding(.vertical)

                    NavigationLink("Input Environmental Data", destination: DataEnterView())
                    Button("History") {
                        showingHistory.toggle()
                    }
                    Button("Show Scatter Plot") {
                        showingScatterPlot.toggle()
                    }
                }

                if showingHistory {
                    Section {
                        ForEach(items) { item in
                            VStack(alignment: .leading) {
                                Text("API Temp: \(item.apiTemperature, specifier: "%.2f")°")
                                Text("API Humidity: \(item.apiHumidity, specifier: "%.2f")%")
                                Text("User Temp: \(item.userTemperature, specifier: "%.2f")°")
                                Text("User Humidity: \(item.userHumidity, specifier: "%.2f")%")
                                Text("Latitude: \(item.latitude, specifier: "%.5f")")
                                Text("Longitude: \(item.longitude, specifier: "%.5f")")
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                }

                if showingScatterPlot {
                    Section {
                        ScatterPlotView()
                            .frame(height: 500)
                    }
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ScatterPlotView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EEntity.userTemperature, ascending: true)],
        animation: .default)
    private var items: FetchedResults<EEntity>

    var body: some View {
        VStack {
            Text("User vs API Scatter Plot").font(.title).padding()

            Chart {
                ForEach(items, id: \.objectID) { item in
                    PointMark(
                        x: .value("Humidity", item.userHumidity),
                        y: .value("Temperature", item.userTemperature)
                    )
                    .foregroundStyle(.red)
                    .annotation(position: .top, alignment: .center) {
                        Text("User").font(.caption).foregroundColor(.red)
                    }
                    
                    // API data point
                    PointMark(
                        x: .value("Humidity", item.apiHumidity),
                        y: .value("Temperature", item.apiTemperature)
                    )
                    .foregroundStyle(.blue)
                    .annotation(position: .top, alignment: .center) {
                        Text("API").font(.caption).foregroundColor(.blue)
                    }
                }
            }
            .frame(height: 400)
            
            HStack {
                HStack {
                    Circle().fill(Color.red).frame(width: 10, height: 10)
                    Text("User Data")
                }
                HStack {
                    Circle().fill(Color.blue).frame(width: 10, height: 10)
                    Text("API Data")
                }
            }
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
