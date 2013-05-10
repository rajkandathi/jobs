//
//  OnMyWayViewController.m
//  OnMyWay
//
//  Created by Raj Kandathi on 5/9/13.
//  Copyright (c) 2013 Raj K. All rights reserved.
//

#import "OnMyWayViewController.h"

@interface OnMyWayViewController ()
@property (weak, nonatomic) IBOutlet UILabel *greetingTextLabel;
@property (nonatomic, strong) ABPeoplePickerNavigationController *peoplePicker;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL didPickDestination;
@property (nonatomic, strong) OnMyWayContact *contact;

@end

@implementation OnMyWayViewController
@synthesize greetingTextLabel = _greetingTextLabel;
@synthesize peoplePicker = _peoplePicker;
@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;
@synthesize didPickDestination = _didPickDestination;

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

- (void)updateGreetingLabel
{
    //TODO: Try and figure to use an attribute string here.
    NSMutableString *greeting = [[NSMutableString alloc] init];
    if (self.didPickDestination) {
        if (self.contact. destinationContactName) {
            [greeting appendString:self.contact.destinationContactName];
            [greeting appendString:@", "];
        }
    } else {
        [greeting appendString:@"<Tap '+' to pick a Contact>, "];
    }
    
    [greeting appendString:@"I am on my way to visit you."];
    self.greetingTextLabel.text = greeting;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.peoplePicker.peoplePickerDelegate = self;
    self.locationManager.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.greetingTextLabel.numberOfLines = 3;
    [self updateGreetingLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startLocationManager
{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    //self.locationManager.distanceFilter = 1000;
    [self.locationManager startUpdatingLocation];
}

- (IBAction)AddContact:(id)sender
{
    //TODO: Check to see if location service is available.
    //TODO: Check to see if the app is authorized to use location services.
    [self presentViewController:self.peoplePicker animated:YES completion:nil];
    [self startLocationManager];
}


- (IBAction)sendUpdate:(id)sender {
}

- (void)setLocationFromAddressDictionary:(NSDictionary *)address
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressDictionary:address
                     completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (!error) {
            CLPlacemark *placemark = [placemarks lastObject];
            self.contact.destinationLocation = placemark.location;
            NSLog(@"%@", self.contact.destinationLocation);
        }
    }];
}


- (NSDictionary *)getAddressOfPerson:(ABRecordRef)person
{
    ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
    NSArray  *addressArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(address);
    NSDictionary *addressDictionary = [addressArray lastObject];
    return addressDictionary;
}

- (NSString *)getPersonName:(ABRecordRef)person
{
    NSString *fullName = (__bridge NSString *)(ABRecordCopyCompositeName(person));
    return fullName;
}

/*
 This method is looking for mobile number from the contact.
 Could also be extended to look for other numbers if Mobile isn't available 
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

#pragma mark ABPeoplePickerNavigationControllerDelegate methods.

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    self.didPickDestination = YES;
    self.contact.destinationContactName = [self getPersonName:person];
    self.contact.destinationContactNumber = [self getPhoneNumber:person];
    [self dismissViewControllerAnimated:YES completion:^{
        if (person) {
            
            NSDictionary *address = [self getAddressOfPerson:person];
            if (!address) {
                //TODO:Show an Error Message. "No Address"
            } else {
                //self.destinationLocation = [self getLocationFromAddressDictionary:address];
                [self setLocationFromAddressDictionary:address];
            }
        } else {
            //TODO:Show an Error Message. "Invalid Contact"
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
        NSLog(@"%@", self.currentLocation);  
        if (location.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            [self.locationManager stopUpdatingLocation];
        }
    }
}




@end
