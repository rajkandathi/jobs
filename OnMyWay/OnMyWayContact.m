//
//  OnMyWayContact.m
//  OnMyWay
//
//  Created by Raj Kandathi on 5/10/13.
//  Copyright (c) 2013 Raj K. All rights reserved.
//

#import "OnMyWayContact.h"

@implementation OnMyWayContact

@synthesize destinationContactName = _destinationContactName;
@synthesize destinationContactNumber = _destinationContactNumber;
@synthesize destinationLocation = _destinationLocation;
@synthesize destinationAddress = _destinationAddress;

- (NSString *)destinationContactName
{
    if (!_destinationContactName) {
        _destinationContactName = [[NSString alloc] init];
    }
    return _destinationContactName;
}

- (NSString *)destinationContactNumber
{
    if (!_destinationContactNumber) {
        _destinationContactNumber = [[NSString alloc] init];
    }
    return _destinationContactNumber;
}

- (CLLocation *)destinationLocation
{
    if (!_destinationLocation) {
        _destinationLocation = [[CLLocation alloc] init];
    }
    return _destinationLocation;
}

- (NSDictionary *)destinationAddress
{
    if (!_destinationAddress) {
        _destinationAddress = [[NSDictionary alloc] init];
    }
    return _destinationAddress;
}

@end
