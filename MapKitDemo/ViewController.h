//
//  ViewController.h
//  MapKitDemo
//
//  Created by Filelife on 2017/8/1.
//  Copyright © 2017年 Filelife. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapMarkBtn.h"
#import "MyPinAnnotation.h"
@interface ViewController : UIViewController
@property (nonatomic, strong) IBOutlet MKMapView * mapView;
@property (nonatomic, strong) IBOutlet UIButton * recordCoordinate;
@property (nonatomic, strong) IBOutlet UISwitch * navSwitch;
@property (nonatomic, strong) IBOutlet UILabel * locationLab;
@property (nonatomic, strong) IBOutlet UIButton * navBtn;
@property (nonatomic, strong) IBOutlet UISegmentedControl * seg;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) MKPointAnnotation * centerPoint;
@property (nonatomic, strong) CLGeocoder * geocoder;
@property (nonatomic, assign) CLLocationCoordinate2D myPlace;
@property (nonatomic, assign) CLLocationCoordinate2D finishPlace;
@property (nonatomic, assign) BOOL isUseVenderNav;
@property (nonatomic, assign) BOOL firstStarNav;
@property (nonatomic, assign) NSInteger navType;

- (IBAction)segValueChange:(UISegmentedControl *)sender;
- (IBAction)navSwitchValueChange:(UISwitch *)sender ;
- (IBAction)beginNav:(id)sender;
- (IBAction)setPin:(id)sender;

- (void)gotoPlace:(MapMarkBtn *)sender ;
@end

