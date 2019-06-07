import XCTest
import WordPressUI

class WPUIResourcesTest: XCTestCase {

    func testImageLoading() {
        let gravatarImage = UIImage.gravatarPlaceholderImage
        XCTAssertNotNil(gravatarImage)
    }

    func testFancyAlertsLoading() {
        let config = FancyAlertViewController.Config(titleText: "Title",
                                                     bodyText: "Body",
                                                     headerImage: UIImage.gravatarPlaceholderImage,
                                                     dividerPosition: .bottom,
                                                     defaultButton: nil,
                                                     cancelButton: nil,
                                                     neverButton: nil,
                                                     moreInfoButton: nil,
                                                     titleAccessoryButton: nil,
                                                     switchConfig: nil,
                                                     appearAction: nil,
                                                     dismissAction: nil)
        let vc = FancyAlertViewController.controllerWithConfiguration(configuration: config)
        XCTAssertNotNil(vc)
    }

}
