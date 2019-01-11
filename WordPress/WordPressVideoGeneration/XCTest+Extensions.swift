import XCTest

extension XCTestCase {

    public func waitForElementToExist(element: XCUIElement, timeout: TimeInterval? = nil) {
        let timeoutValue = timeout ?? 30
        guard element.waitForExistence(timeout: timeoutValue) else {
            XCTFail("Failed to find \(element) after \(timeoutValue) seconds.")
            return
        }
    }

    public func waitForElementToNotExist(element: XCUIElement, timeout: TimeInterval? = nil) {
        let notExistsPredicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: notExistsPredicate,
                                                    object: element)

        let timeoutValue = timeout ?? 30
        guard XCTWaiter().wait(for: [expectation], timeout: timeoutValue) == .completed else {
            XCTFail("\(element) still exists after \(timeoutValue) seconds.")
            return
        }
    }

    func login() {
        let app = XCUIApplication()

        let loginButton = app.buttons["Log In Button"]

        // Logout first if needed
        if !loginButton.waitForExistence(timeout: 3.0) {
            logout()
        }

        loginButton.tap()
        app.buttons["Self Hosted Login Button"].tap()

        // We have to login by site address, due to security issues with the
        // shared testing account which prevent us from signing in by email address.
        let selfHostedUsernameField = app.textFields["usernameField"]
        waitForElementToExist(element: selfHostedUsernameField)
        selfHostedUsernameField.tap()
        selfHostedUsernameField.typeText("WordPress.com")
        app.buttons["Next Button"].tap()

        let usernameField = app.textFields["usernameField"]
        let passwordField = app.secureTextFields["passwordField"]

        waitForElementToExist(element: passwordField)
        usernameField.tap()
        usernameField.typeText(VideoCredentials.username)
        passwordField.tap()
        passwordField.typeText(VideoCredentials.password)

        app.buttons["submitButton"].tap()

        let continueButton = app.buttons["Continue"]
        waitForElementToExist(element: continueButton)
        continueButton.tap()

        // Wait for the notification primer, and accept if present
        // This also removes the notification prompt from the Notifications tab
        let acceptAlertButton = app.buttons["defaultAlertButton"]
        if acceptAlertButton.waitForExistence(timeout: 3.0) {
            acceptAlertButton.tap()
            allowDeviceAccess()
        }
    }

    func logout() {
        let app = XCUIApplication()
        app.tabBars["Main Navigation"].buttons["meTabButton"].tap()

        let loginButton = app.buttons["Log In Button"]
        let logoutButton = app.tables.element(boundBy: 0).cells.element(boundBy: 5)
        let logoutAlert = app.alerts.element(boundBy: 0)

        // The order of cancel and log out in the alert varies by language
        // There is no way to set accessibility identifers on them, so we must try both
        logoutButton.tap()
        logoutAlert.buttons.element(boundBy: 1).tap()

        if !loginButton.waitForExistence(timeout: 3.0) {
            // Still not logged out, try the other button
            logoutButton.tap()
            logoutAlert.buttons.buttons.element(boundBy: 0).tap()
        }

        waitForElementToExist(element: loginButton)
    }

    /**
     Accept device permissions
    */
    func allowDeviceAccess() {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowButton = springboard.buttons.element(boundBy: 1)
        if allowButton.exists {
            allowButton.tap()
        }
    }

    /**
     Selects all entered text in the rich text field
     */
    func selectAllTextInField(field: String) -> Void {
        let app = XCUIApplication()
        let textField = app.textViews[field]

        textField.tap()
        app.menuItems.element(boundBy: 1).tap()
    }

    /**
     Type in rich text field
     */
    func typeToTextField(text: String, to: String) -> Void {
        let app = XCUIApplication()
        let textField = app.textViews[to]

        textField.typeText(text)
    }
}
