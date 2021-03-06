//
//  RecordDetailViewController.swift
//  T1M3
//
//  Created by Graphene on 7/9/18.
//  Copyright © 2018 Bob. All rights reserved.
//

import UIKit
import MapKit
import Charts

class RecordDetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var sideTableView: UITableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var notes: UILabel!
    @IBOutlet weak var graph: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.sideTableView.delegate = self
        self.sideTableView.dataSource = self
        self.mapView.delegate = self
        setupBg()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let record = RecordLog.shared.getSelectedRecord()
        self.updateDetail(record: record)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.sideTableView.reloadData()
        setupBg()
    }
    func setupBg(){
        self.bgImageView.image = Settings.shared.getBgImage()
    }
    func updateDetail(record: Recording){
        let dateString = record.timeStarted.formatTimestamp(withFormat: "MM-dd-yyyy")
        let timeString =  record.timeStarted.formatTimestamp(withFormat: "HH:mm")
        let durationString = Recording.toHumanReadable(elapsedTime: record.finalRecordingElapsed)
        self.dateLbl.text = "Date: \(dateString)"
        self.timeLbl.text = "Time: \(timeString)"
        self.durationLbl.text = "Duration: \(durationString)"
        let notesString = (record.getNotes() == "") ? "This record doesn't have any notes ": record.getNotes()
        self.notes.text = notesString
        setupMap(recording: record)
        setupGraph()
        updateData(data: fixData(data: record.accData))

    }
}
extension RecordDetailViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecordLog.shared.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = RecordLog.shared.records[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideTableCell") as! SideTableCell
        cell.setup(record: record)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        selectedIndex = indexPath.row
        RecordLog.shared.setSelectedIndex(index: indexPath.row)
        let record = RecordLog.shared.getSelectedRecord()
        self.updateDetail(record: record)

    }
}

extension RecordDetailViewController: MKMapViewDelegate {
    func setupMap(recording: Recording) {
        
        guard let startCoordinates = recording.startLocation,
            let endCoordinates = recording.endLocation else { return }
        let centerLat = (startCoordinates.latitude + endCoordinates.latitude) / 2
        let centerLon = (startCoordinates.longitude + endCoordinates.longitude) / 2
        
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan.init(latitudeDelta: 0.2, longitudeDelta: 0.2))
        mapView.setRegion(region, animated: false)
        
        
        let startAnnotiation = MKPointAnnotation.init()

        startAnnotiation.coordinate = startCoordinates
        startAnnotiation.title = "Start"
        
        mapView.addAnnotation(startAnnotiation)
        
        let endAnnotiation = MKPointAnnotation.init()
        endAnnotiation.coordinate = endCoordinates
        endAnnotiation.title = "End"

        mapView.addAnnotation(endAnnotiation)
        mapView.showAnnotations([startAnnotiation,endAnnotiation], animated: false)
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "location") as? MKPinAnnotationView {
            pinView.annotation = annotation
            pinView.pinTintColor = annotation.title == "Start" ? .red : .blue
            return pinView
        } else {
            let pinAnnotation = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "location")
            pinAnnotation.pinTintColor = annotation.title == "Start" ? .red : .blue
            
        }
        return nil

    }
    
    func setupGraph() {
        graph.xAxis.enabled = false
        graph.leftAxis.enabled = false
        graph.rightAxis.enabled = false
        graph.legend.enabled = false
        graph.chartDescription?.enabled = false
        graph.isUserInteractionEnabled = false
    }
    
    func fixData(data: [(x: Double, y: Double)]) -> [(x: Double, y: Double)] {
        var dataDictionary: [Double: [Double]] = [:]
        data.forEach { (dataPoint) in
            if var currentArray = dataDictionary[dataPoint.x] {
                currentArray.append(dataPoint.y)
                dataDictionary[dataPoint.x] = currentArray
            }
            else {
                dataDictionary[dataPoint.x] = [dataPoint.y]
            }
        }
        return dataDictionary.flatMap{ (x: $0.key, y: $0.value.first) as? ChartPoint  }.sorted(by: { (one, two) -> Bool in
            return one.x < two.x
        })    // Change to average if time
    }
    
    typealias ChartPoint = (x: Double, y: Double)
    
    func updateData(data: [(x: Double, y: Double)]) {
        let values = data.compactMap{ChartDataEntry.init(x: $0.x, y: $0.y)}
        let set = LineChartDataSet(values: values, label: "")
        set.mode = .cubicBezier
        set.drawCirclesEnabled = false
        set.lineWidth = 1.8
        set.circleRadius = 4
        set.setCircleColor(.white)
        set.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set.fillColor = .blue
        set.fillAlpha = 0
        set.drawHorizontalHighlightIndicatorEnabled = false
        set.fillFormatter = CubicLineSampleFillFormatter()
        
        let data = LineChartData(dataSet: set)
        
        data.setDrawValues(false)
        graph.data = data
    }
    
}
