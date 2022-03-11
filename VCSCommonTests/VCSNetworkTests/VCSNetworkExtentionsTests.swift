import XCTest

class VCSNetworkExtentionsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDateISO8061() {
        let dateString = "2019-06-17T10:51:50.347Z"
        let dateYear = 2019
        let dateMonth = 06
        let dateDay = 17
        let dateHour = 10
        let dateMinute = 51
        let dateSecond = 50
        let dateNanosecond = 346999883
        
        guard let date = dateString.VCSDateFromISO8061 else {
            XCTAssert(false)
            return
        }
        
        let dateComponents = Calendar(identifier: .iso8601).dateComponents(in: TimeZone(abbreviation: "UTC")!, from: date)
        XCTAssert(dateComponents.year == dateYear)
        XCTAssert(dateComponents.month == dateMonth)
        XCTAssert(dateComponents.day == dateDay)
        
        XCTAssert(dateComponents.hour == dateHour)
        XCTAssert(dateComponents.minute == dateMinute)
        XCTAssert(dateComponents.second == dateSecond)
        XCTAssert(dateComponents.nanosecond == dateNanosecond)
    }

}
