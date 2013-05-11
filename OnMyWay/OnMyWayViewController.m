//
//  OnMyWayViewController.m
//  OnMyWay
//
//  Created by Raj Kandathi on 5/9/13.
//  Copyright (c) 2013 Raj K. All rights reserved.
//


/**
 * The controller lets you pick a contact from your contact and
 * helps you send a message to your contact along with your 
 * distance details.
 **/

#import "OnMyWayViewController.h"

@interface OnMyWayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *greetingTextLabel;
@property (nonatomic, strong) ABPeoplePickerNavigationController *peoplePicker;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL didPickDestination;
@property (nonatomic, strong) OnMyWayContact *contact;
@property (weak, nonatomic) IBOutlet UIButton *sendUpdatesButton;

@end

@implementation OnMyWayViewController
@synthesize greetingTextLabel = _greetingTextLabel;
@synthesize peoplePicker = _peoplePicker;
@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;
@synthesize didPickDestination = _didPickDestination;
@synthesize sendUpdatesButton = _sendUpdatesButton;


- (ABPeoplePickerNavigationController *)peoplePicker
{
    if (!_peoplePicker) {
        _peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    }
    return _peoplePicker;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

- (OnMyWayContact *)contact
{
    if (!_contact) {
        _contact = [[OnMyWayContact alloc] init];
    }
    return _contact;
}

//Alert View to display various error conditions. 
- (void)showAlertMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hey there!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

/* The method initializes the greeting message on the main Screen along
 * with a mini instruction. Attributed strings are used for fun to achieve
 * different colors within the label message.
 */
- (void)updateGreetingLabel
{
    NSMutableString *greeting = [[NSMutableString alloc] init];
    NSString *instruction = @"<Tap '+' to pick a Contact>";
    NSString *commaSpace = @", ";
    if (self.didPickDestination) {
        if (self.contact.destinationContactName) {
            [greeting appendString:self.contact.destinationContactName];
            [greeting appendString:commaSpace];
        }
    } else {
        [greeting appendString:instruction];
        [greeting appendString:commaSpace];
    }
    
    [greeting appendString:@"I am on my way to visit you."];
    
    NSMutableAttributedString *attributedGreeting = [[NSMutableAttributedString alloc] initWithString:greeting];
    if (self.didPickDestination) {
        [attributedGreeting addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor]
                                   range:NSMakeRange(0,self.contact.destinationContactName.length)];
    } else {
        [attributedGreeting addAttribute:NSForegroundColorAttributeName value:[UIColor redColor]
                                   range:NSMakeRange(0,instruction.length)];
    }
    [self.greetingTextLabel setAttributedText: attributedGreeting];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Assigning as delegate for ABPeoplePickerNavigationController & CLLocationManager.
    self.peoplePicker.peoplePickerDelegate = self;
    self.locationManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Initializing the greeting label.
    self.greetingTextLabel.numberOfLines = 3;
    [self updateGreetingLabel];
}

//Initializes the location manager with minimal properties.
- (void)startLocationManager
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [self.locationManager startUpdatingLocation];
}

//Composes the text message that you send to your contact.
- (NSString *)getMessage
{
    NSMutableString *message = [[NSMutableString alloc] initWithString:@"Hey"];
    [message appendString:@" "];
    [message appendString:self.contact.destinationContactName];
    [message appendString:@", "];
    [message appendString:@"I am on my way to visit you and I am"];
    [message appendString:@" "];
    int distance = round([self.currentLocation distanceFromLocation:self.contact.destinationLocation] * 0.00062137);
    [message appendString:[NSString stringWithFormat:@"%i",distance]];
    [message appendString:@" "];
    [message appendString:@"miles away."];
    
    return message;
}

//Kicks of the MFMessageComposeViewController with required details to send a text message.
- (void)sendMessageToContact
{
    MFMessageComposeViewController *mfMessageComposeViewController = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        mfMessageComposeViewController.recipients = [NSArray arrayWithObject:self.contact.destinationContactNumber];
        mfMessageComposeViewController.body = [self getMessage];
        mfMessageComposeViewController.messageComposeDelegate = self;
        [self presentViewController:mfMessageComposeViewController animated:YES completion:nil];        
    }
}

//Forward lookup of the address to get location co-ordinates.
- (void)getLocationFromAddressDictionary:(NSDictionary *)address
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressDictionary:address
                     completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!error) {
             CLPlacemark *placemark = [placemarks lastObject];
             self.contact.destinationLocation = placemark.location;
             [self sendMessageToContact];
         } else {
             [self showAlertMessage:@"oops, there was some problem looking up the location. Sorry :("];
         }
     }];
}

//Action to pick contact. Also validates necessary compatibility for the app to work.
- (IBAction)AddContact:(id)sender
{
    //TODO: Check to see if location service is available.
    //TODO: Check to see if the app is authorized to use location services.
    [self presentViewController:self.peoplePicker animated:YES completion:nil];
    [self startLocationManager];
}

- (IBAction)sendUpdate:(id)sender
{
    [self getLocationFromAddressDictionary:self.contact.destinationAddress];
}

//Reads Address details for a given contact.
- (NSDictionary *)getAddressOfPerson:(ABRecordRef)person
{
    ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
    NSArray  *addressArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(address);
    NSDictionary *addressDictionary = [addressArray lastObject];
    return addressDictionary;
}

//Reads the contact name.
- (NSString *)getPersonName:(ABRecordRef)person
{
    NSString *fullName = (__bridge NSString *)(ABRecordCopyCompositeName(person));
    return fullName;
}

/*
 This method is looking for mobile number from the contact.
 Note: could also be extended to look for other numbers if Mobile isn't available 
*/
- (NSString *)getPhoneNumber:(ABRecordRef)person
{
    NSString *phoneNumber = @"";
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if (phones != nil && ABMultiValueGetCount(phones) > 0) {
        phoneNumber = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phones, 0);
    }
    return phoneNumber;
}

#pragma mark MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	switch (result) {
		case MessageComposeResultCancelled:
			break;
		case MessageComposeResultFailed:
            break;
		case MessageComposeResultSent:
			break;
		default:
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods.

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    if (!person) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self showAlertMessage:@"Looks like you choose an invalid contact. Pick a different contact."];
        }];
        return NO;
    }
    self.didPickDestination = YES;
    self.contact.destinationContactName = [self getPersonName:person];
    self.contact.destinationContactNumber = [self getPhoneNumber:person];
    [self dismissViewControllerAnimated:YES completion:^{
        NSDictionary *address = [self getAddressOfPerson:person];
        if (!address) {
            [self showAlertMessage:@"Looks like you don't have an address saved for your contact. Save an address to send update messages."];
        } else {
            self.contact.destinationAddress = address;
        }
    }];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

#pragma mark CLLocationManagerDelegate methods.

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    
    if ([location.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    if (location.horizontalAccuracy < 0) {
        return;
    }
    if (self.currentLocation == nil || self.currentLocation.horizontalAccuracy > location.horizontalAccuracy)
    {
        self.currentLocation = location;
        if (location.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            [self.locationManager stopUpdatingLocation];
        }
    }
}

@end
