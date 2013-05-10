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
@property (nonatomic, strong) CLLocation *destinationLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation OnMyWayViewController
@synthesize greetingTextLabel = _greetingTextLabel;
@synthesize peoplePicker = _peoplePicker;
@synthesize destinationLocation = _destinationLocation;
@synthesize currentLocation = _currentLocation;
@synthesize locationManager = _locationManager;

- (ABPeoplePickerNavigationController *)peoplePicker
{
    if (!_peoplePicker) {
        _peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    }
    return _peoplePicker;
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
    self.greetingTextLabel.numberOfLines = 2;
    
    //TODO: Try and figure to use an attribute string here.
    self.greetingTextLabel.text = @"I am on my way to visit, <Tap Below to add Contact>";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)AddContact:(id)sender
{
    //TODO: Check to see if location service is available.
    //TODO: Check to see if the app is authorized to use location services.
    [self presentViewController:self.peoplePicker animated:YES completion:nil];
}

- (void)setLocationFromAddressDictionary:(NSDictionary *)address
{
    __block CLLocation *location = nil;
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressDictionary:address
                     completionHandler:^(NSArray *placemarks, NSError *error)
    {
        if (!error) {
            CLPlacemark *placemark = [placemarks lastObject];
            location = placemark.location;
            NSLog(@"%@", location);
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

#pragma mark ABPeoplePickerNavigationControllerDelegate methods.

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
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
    
}



@end
