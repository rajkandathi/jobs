//
//  OnMyWayContact.h
//  OnMyWay
//
//  Created by Raj Kandathi on 5/10/13.
//  Copyright (c) 2013 Raj K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

//Model to hold contact information.

@interface OnMyWayContact : NSObject

@property (nonatomic, strong) NSString *destinationContactName;
@property (nonatomic, strong) NSString *destinationContactNumber;
@property (nonatomic, strong) CLLocation *destinationLocation;
@property (nonatomic, strong) NSDictionary *destinationAddress;

@end
