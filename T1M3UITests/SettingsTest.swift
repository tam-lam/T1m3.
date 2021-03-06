//
//  SettingsTest.swift
//  T1M3UITests
//
//  Created by Bob on 9/16/18.
//  Copyright © 2018 Bob. All rights reserved.
//

import XCTest

class SettingsTest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAllSettingsArePresent() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        XCTAssert(app.tables/*@START_MENU_TOKEN@*/.staticTexts["Dark/Light mode"]/*[[".cells.staticTexts[\"Dark\/Light mode\"]",".staticTexts[\"Dark\/Light mode\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists)
        XCTAssert(app.tables/*@START_MENU_TOKEN@*/.staticTexts["Version"].exists)
        XCTAssert(app.tables/*@START_MENU_TOKEN@*/.staticTexts["Team"].exists)
    }
    
}
