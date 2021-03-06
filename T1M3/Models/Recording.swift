//
//  Recording.swift
//  T1M3
//
//  Created by Bob on 9/19/18.
//  Copyright © 2018 Bob. All rights reserved.
//

import Foundation
import CoreLocation

public class Recording: NSObject {
    public static var dummyRecording: Recording = {
        let record = Recording()
        record.timeStarted = Date().timeIntervalSince1970
        record.editedDuration = 5.0
        record.accData = [(0,1),(1,2),(2,0),(3,5),(4,5),(5,3)]
        record.weather = .rainy
        return record
    }()
    
    public var timeStarted: Double = 0
    public var timeFinished: Double?
    public var pauseTimes: [(pauseTime: Double, resumeTime: Double)] = []
    public var accData: [(x: Double, y: Double)] = []
    public var weather: WeatherSituation = .none
    private var accRecorder: AccelerometerManager? = AccelerometerManager()
    public var notes: String = ""
    public var editedDuration: Double?
    public var didUpdate: (() -> (Void))?
    
    public func setNotes(notes: String){
        self.notes = notes
    }
    public func getNotes()->String{
        return self.notes
    }
    
    public var startLocation: CLLocationCoordinate2D?
    public var startLocationName: String?
    public var endLocation: CLLocationCoordinate2D?
    
    public var totalRecordingElapsed: Double {
        let intermissions = pauseTimes.reduce(0) { $0 + $1.resumeTime - $1.pauseTime }
        let total = ( Date().timeIntervalSince1970 - timeStarted) - intermissions
        return total
    }
    
    public var finalRecordingElapsed: Double {
        if let editedDuration = editedDuration {
            return editedDuration
        }
        let intermissions = pauseTimes.reduce(0) { $0 + $1.resumeTime - $1.pauseTime }
        let total = ( (pauseTimes.last?.pauseTime ?? 0.0) - timeStarted) - intermissions
        return total
    }
    
    public static func toHumanReadable(elapsedTime: Double) -> String {
        let decimalValue = Int((elapsedTime - Double(Int(elapsedTime))) * 100)
        return "\(Int(elapsedTime)):\(decimalValue >= 10 ? String(decimalValue) : "0\(decimalValue)")"
    }
    
    public func start() {
        timeStarted = Date().timeIntervalSince1970
        AccelerometerManager.shared.addReceiver(receiver: self)
        
        self.startLocation = LocationManager.shared.lastLocation.coordinate
        
        WeatherInformationManager.getWeatherInformation(forCoordinates: LocationManager.shared.lastLocation.coordinate) { [weak self] (weather) in
            guard let strongSelf = self else { return }
            strongSelf.weather = weather
            strongSelf.didUpdate?()
            RecordLog.shared.updateRecording(record: strongSelf)
        }
        LocationManager.shared.geocode(LocationManager.shared.lastLocation.coordinate) { [weak self] (cityName) -> (Void) in
            guard let strongSelf = self else { return }
            strongSelf.startLocationName = cityName
            strongSelf.didUpdate?()
            RecordLog.shared.updateRecording(record: strongSelf)
        }
    }
    
    public func stopRecording() {
        timeFinished = Date().timeIntervalSince1970
        AccelerometerManager.shared.removeReceiver(receiver: self)
        accRecorder = nil
        self.endLocation = LocationManager.shared.lastLocation.coordinate
    }
}

extension Recording: AccDataReceiver {
    public func newData(data: Double) {
        accData.append((x: Double(Int(Date().timeIntervalSince1970 - timeStarted)), y: data))
    }
}
