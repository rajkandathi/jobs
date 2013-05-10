//
//  OnMyWayViewController.h
//  OnMyWay
//
//  Created by Raj Kandathi on 5/9/13.
//  Copyright (c) 2013 Raj K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import "OnMyWayContact.h"


@interface OnMyWayViewController : UIViewController
<ABPeoplePickerNavigationControllerDelegate, CLLocationManagerDelegate>

@end
