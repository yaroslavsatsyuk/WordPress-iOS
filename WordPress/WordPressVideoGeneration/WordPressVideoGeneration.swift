import XCTest

class WordPressVideoGeneration: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        if isPad {
            XCUIDevice().orientation = UIDeviceOrientation.landscapeLeft
        } else {
            XCUIDevice().orientation = UIDeviceOrientation.portrait
        }

        login()

        // Dismiss device permissions alerts
        // Media permissions
        let blogDetailsTable = app.tables["Blog Details Table"]
        blogDetailsTable/*@START_MENU_TOKEN@*/.staticTexts["Media"]/*[[".cells.matching(identifier: \"BlogDetailsCell\").staticTexts[\"Media\"]",".staticTexts[\"Media\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let mediaNavigationBar = app.navigationBars["Media"]
        mediaNavigationBar.buttons["Add"].tap()
        allowDeviceAccess()
        app.sheets.element(boundBy: 0).buttons["Dismiss"].tap()
        mediaNavigationBar.buttons.element(boundBy: 0).tap()

        // Open Blog Posts
        blogDetailsTable.cells["Blog Post Row"].tap() // tap Blog Posts
        waitForElementToExist(element: app.tables["PostsTable"])
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        // Reset site state
        let app = XCUIApplication()

        // Start on My Sites tab
        let mainNavigationTabBar = app.tabBars["Main Navigation"]
        mainNavigationTabBar.buttons["mySitesTabButton"].tap()
        mainNavigationTabBar.buttons["mySitesTabButton"].tap()
        app.tables["Blogs"].cells.element(boundBy: 0).tap()

        // Reset Stats to Insights tab
        app.tables["Blog Details Table"]/*@START_MENU_TOKEN@*/.staticTexts["Stats"]/*[[".cells[\"Stats Row\"].staticTexts[\"Stats\"]",".staticTexts[\"Stats\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Insights"].tap()
        app.navigationBars["Stats"].buttons.element(boundBy: 0).tap()

        // Open Blog Posts
        let blogDetailsTable = app.tables["Blog Details Table"]
        blogDetailsTable.cells["Blog Post Row"].tap() // tap Blog Posts
        waitForElementToExist(element: app.tables["PostsTable"])

        // Tap on the first post to bring up the editor
        app.tables["PostsTable"].tap()

        let editorNavigationBar = app.navigationBars["Azctec Editor Navigation Bar"]
        waitForElementToExist(element: editorNavigationBar)

        // Load the previous post revision
        editorNavigationBar.buttons["More"].tap()
        app.sheets.element(boundBy: 0).buttons["History"].tap()
        app.tables.element(boundBy: 0).cells.element(boundBy: 1).tap()
        app.navigationBars["Revision"].buttons["Load"].tap()

        // Update the post and go back to My Sites
        waitForElementToExist(element: editorNavigationBar)
        editorNavigationBar.buttons["Update"].tap()
        editorNavigationBar.buttons["Close"].tap()
        app.navigationBars["Blog Posts"].buttons.element(boundBy: 0).tap()

        waitForElementToExist(element: mainNavigationTabBar)

        // Open Notifications
        let notificationstabButton = mainNavigationTabBar/*@START_MENU_TOKEN@*/.buttons["notificationsTabButton"]/*[[".buttons[\"Notifications\"]",".buttons[\"notificationsTabButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        notificationstabButton.tap()

        // Reset the comment like
        app.tables["Notification Details Table"].buttons["Liked"].tap()

        sleep(2) // Give some time for the last action to complete

        super.tearDown()
    }

    func testGenerateVideo() {
        let app = XCUIApplication()

        sleep(5) // for now, use this to give us a pause for editing

        // Tap on the first post to bring up the editor
        app.tables["PostsTable"].tap()

        let editorNavigationBar = app.navigationBars["Azctec Editor Navigation Bar"]
        waitForElementToExist(element: editorNavigationBar)

        // The title field gets focus automatically
        // Tap into the post content area and replace text
        let richContentTextView = app.textViews["Rich Content"]
        richContentTextView.tap()
        selectAllTextInField(field: "Rich Content")
        typeToTextField(text: "☕️ This event is now sold out!", to: "Rich Content")

        sleep(1) // Give viewers time to process what's on screen

        // Update the post and go back to My Sites
        editorNavigationBar.buttons["Update"].tap()
        editorNavigationBar.buttons["Close"].tap()
        app.navigationBars["Blog Posts"].buttons.element(boundBy: 0).tap()

        let mainNavigationTabBar = app.tabBars["Main Navigation"]
        waitForElementToExist(element: mainNavigationTabBar)

        // Open Stats
        app.tables["Blog Details Table"]/*@START_MENU_TOKEN@*/.staticTexts["Stats"]/*[[".cells[\"Stats Row\"].staticTexts[\"Stats\"]",".staticTexts[\"Stats\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(1) // Give viewers time to process the Insights stats
        app.buttons["Days"].tap()
        sleep(1) // Give viewers time to process today's stats

        // Open Notifications
        let notificationstabButton = mainNavigationTabBar/*@START_MENU_TOKEN@*/.buttons["notificationsTabButton"]/*[[".buttons[\"Notifications\"]",".buttons[\"notificationsTabButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        notificationstabButton.tap()

        // Open and like comment notification
        let notificationsTable = app.tables["Notifications Table"]
        waitForElementToExist(element: notificationsTable)
        notificationsTable.staticTexts["Amechie Ajimobi commented on Coffee Tasting Event"].tap()
        sleep(1) // Give viewers time to process the notification detail
        app.tables["Notification Details Table"].buttons["Like"].tap()

        sleep(5) // for now, use this to give us a pause for editing
    }
}
