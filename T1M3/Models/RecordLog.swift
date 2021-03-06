//
//  RecordLog.swift
//  T1M3
//
//  Created by Bob on 8/29/18.
//  Copyright © 2018 Bob. All rights reserved.
//

import Foundation
import CoreData

protocol DataModelDelegate: class {
    func didReceiveAddedRecord(record: Recording)
    func didRecordsVCRecieveDeleteIndex(index: Int)
    func didDetailVCRecieveDeleteIndex(index: Int)
    func didDetailVCRecieveReplacement(replacement: Recording, index: Int)
}

class RecordLog {
    weak var delegate: DataModelDelegate?

    var coreDataRecordLog: [NSManagedObject] = []
    var selectedIndex : Int
    public  static let shared = RecordLog()
    
    private init(){
        self.selectedIndex = 0
    }
    
    public private(set) var records: [Recording] = []
    
    // UNCOMMENT FOLLOWING LINE FOR SAMPLE DATA
//    public private(set) var records: [Recording] = [Recording.dummyRecording]
    
    public func addRecord(record: Recording) {
        records.append(record)
        delegate?.didReceiveAddedRecord(record: record)

    }
    public func addRecordOnlyToSingleton(record:Recording){
        records.append(record)
    }
    
    public func addRecordAtIndex(record: Recording, destinationIndex: Int){
        records.insert(record, at: destinationIndex)
    }
    public func removeRecord(index: Int){
        if records.indices.contains(index){
            records.remove(at: index)
            delegate?.didRecordsVCRecieveDeleteIndex(index: index)
        }
    }
    public func removeAllRecords(){
        records.removeAll()
    }
    public func getSelectedIndex() -> Int {
        return selectedIndex
    }
    public func setSelectedIndex(index:Int){
        self.selectedIndex = index
    }
    public func getSelectedRecord() ->Recording {
        let record = RecordLog.shared.records[selectedIndex]
        return record
    }
    public func deleteSelectedRecord(){
        records.remove(at: selectedIndex)
        delegate?.didDetailVCRecieveDeleteIndex(index: selectedIndex)
    }
    
    public func replaceRecord(record: Recording, index: Int) {
        records[index] = record
        delegate?.didDetailVCRecieveReplacement(replacement: record, index: index)
    }
    
    public func updateRecording(record: Recording) {
        guard let index = records.index(of: record) else { return }
        delegate?.didDetailVCRecieveReplacement(replacement: record, index: index)
    }
}
