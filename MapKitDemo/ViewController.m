//
//  ViewController.m
//  MapKitDemo
//
//  Created by Filelife on 2017/8/1.
//  Copyright © 2017年 Filelife. All rights reserved.
//

#import "ViewController.h"
#define HEX_RGBA(s,a) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s & 0xFF))/255.0 alpha:a]

@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _firstStarNav = YES;
    self.geocoder = [[CLGeocoder alloc]init];
    [self initMapView];
    [self setCenterAnnotation];
    [self setLocationLabel];
    [self setSwitch];
    [self recordCoordinateBtnInit];
    [self navigationBtn];
    [self startStandardUpdates];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI

- (void)initMapView {
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeMutedStandard;
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    //Just a location
    double lat = 24.489224794270353f;
    double lon = 118.18014079685172f;
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat , lon), 300, 194)
                   animated:YES];
}

- (void)setCenterAnnotation {
    self.centerPoint = [[MKPointAnnotation alloc] init];
    self.centerPoint.coordinate = self.mapView.region.center;
    self.centerPoint.title = @"Screen Center";
    [self.mapView addAnnotation:self.centerPoint];
}

- (void)setLocationLabel {
    self.locationLab.textColor = HEX_RGBA(0xff5a8d, 1);
    self.locationLab.text = [NSString stringWithFormat:@"(%.5lf ,%.5lf)",self.mapView.region.center.latitude,self.mapView.region.center.longitude];
    
}

- (void)setSwitch {
    _isUseVenderNav = NO;
    self.navSwitch.on = NO;
}


- (void)recordCoordinateBtnInit {
    _recordCoordinate.layer.masksToBounds = YES;
    _recordCoordinate.layer.borderColor = HEX_RGBA(0xff5a8d, 1).CGColor;
    _recordCoordinate.layer.borderWidth = 1;
    _recordCoordinate.layer.cornerRadius = 3;
}

- (void)navigationBtn {
    _navBtn.layer.masksToBounds = YES;
    _navBtn.layer.borderColor = HEX_RGBA(0xff5a8d, 1).CGColor;
    _navBtn.layer.borderWidth = 1;
    _navBtn.layer.cornerRadius = 3;
}

#pragma mark - Action

- (IBAction)segValueChange:(UISegmentedControl *)sender {
    _navType = sender.numberOfSegments;
}

- (IBAction)navSwitchValueChange:(UISwitch *)sender {
    _isUseVenderNav = sender.on;
    
}

- (IBAction)beginNav:(id)sender {
    if(_isUseVenderNav) {
        [self navByVender];
    } else {
        [self navBySelfieCity];
    }
}

- (IBAction)setPin:(id)sender {
    
    [self setCoordinatePin:[_mapView region].center];
}

- (void)gotoPlace:(MapMarkBtn *)sender {
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.myPlace addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:sender.coordinate addressDictionary:nil];
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    [self findDirectionsFrom:fromItem to:toItem];
}

#pragma mark - Navigation
- (void)navBySelfieCity {
    
    MKPlacemark *fromPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.myPlace addressDictionary:nil];
    MKPlacemark *toPlacemark   = [[MKPlacemark alloc] initWithCoordinate:self.finishPlace addressDictionary:nil];
    MKMapItem *fromItem = [[MKMapItem alloc] initWithPlacemark:fromPlacemark];
    MKMapItem *toItem   = [[MKMapItem alloc] initWithPlacemark:toPlacemark];
    
    [self findDirectionsFrom:fromItem to:toItem];
}

-(void)findDirectionsFrom:(MKMapItem *)from to:(MKMapItem *)to{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = from;
    request.destination = to;
    request.transportType = MKDirectionsTransportTypeWalking;
    
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    //ios7获取绘制路线的路径方法
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error info:%@", error.userInfo[@"NSLocalizedFailureReason"]);
        }
        else {
            for (MKRoute *route in response.routes) {
                
//                MKRoute *route = response.routes[0];
                for(id<MKOverlay> overLay in self.mapView.overlays) {
                    [self.mapView removeOverlay:overLay];
                }
                
                [self.mapView addOverlay:route.polyline level:0];
                double lat = self.mapView.region.center.latitude;
                double lon = self.mapView.region.center.longitude;
                double latDelta = self.mapView.region.span.latitudeDelta * 100000;
                double lonDelta = self.mapView.region.span.longitudeDelta * 100000;
                if(_firstStarNav) {
                    _firstStarNav = NO;
                    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lat , lon), 200, 126)
                                   animated:YES];

                }
                
                
                
            }
            
        }
    }];
}

- (void)navByVender {
    
    CLLocation *begin = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:self.myPlace.latitude] floatValue]
                                                   longitude:[[NSNumber numberWithFloat:self.myPlace.longitude] floatValue]];
    
    
    [self.geocoder reverseGeocodeLocation:begin completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        __block CLPlacemark * beginPlace = [placemarks firstObject];
        CLLocation *end = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:self.finishPlace.latitude] floatValue]
                                                     longitude:[[NSNumber numberWithFloat:self.finishPlace.longitude] floatValue]];
        
        [self.geocoder reverseGeocodeLocation:end completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if(error) {
                
                NSLog(@"Error Info %@",error.userInfo);
            } else {
                CLPlacemark * endPlace = [placemarks firstObject];
                MKMapItem * beginItem = [[MKMapItem alloc] initWithPlacemark:beginPlace];
                MKMapItem * endItem = [[MKMapItem alloc] initWithPlacemark:endPlace];
                NSString * directionsMode;
                
                switch (self.navType) {
                    case 0:
                        directionsMode = MKLaunchOptionsDirectionsModeWalking;
                        break;
                    case 1:
                        directionsMode = MKLaunchOptionsDirectionsModeDriving;
                        break;
                    case 2:
                        directionsMode = MKLaunchOptionsDirectionsModeTransit;
                        break;
                    default:
                        directionsMode = MKLaunchOptionsDirectionsModeWalking;
                        break;
                }
                
                NSDictionary *launchDic = @{
                                            //范围
                                            MKLaunchOptionsMapSpanKey : @(50000),
                                            // 设置导航模式参数
                                            MKLaunchOptionsDirectionsModeKey : directionsMode,
                                            // 设置地图类型
                                            MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                                            // 设置是否显示交通
                                            MKLaunchOptionsShowsTrafficKey : @(YES),
                                            
                                            };
                [MKMapItem openMapsWithItems:@[beginItem, endItem] launchOptions:launchDic];
            }
            
        }];
    }];
}


#pragma mark - Coordinate Operation
- (CLLocationCoordinate2D)loadLastCenterCoordinate {
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    double lat = [userDefaultes doubleForKey:@"kLastCenterLat"];
    double lon = [userDefaultes doubleForKey:@"kLastCenterLon"];
    return CLLocationCoordinate2DMake(lat , lon);
}

- (void)saveLastCenter:(CLLocationCoordinate2D)center {
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    [userDefaultes setDouble:center.latitude forKey:@"kLastCenterLat"];
    [userDefaultes setDouble:center.longitude forKey:@"kLastCenterLon"];
}


- (void)setCoordinatePin:(CLLocationCoordinate2D)coordinate {
    MyPinAnnotation *annotation = [[MyPinAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = @"Pin";
    annotation.pinIndex = 1;
    annotation.subtitle = @"Text something here.......";
    [_mapView addAnnotation:annotation];
    
}





- (void)startStandardUpdates {
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [_locationManager requestWhenInUseAuthorization];
    }
    if(![CLLocationManager locationServicesEnabled]){
        NSLog(@"Setting > privacy > Location > Navigation");
    }
    if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager startUpdatingLocation];
    //方位服务
    if ([CLLocationManager headingAvailable])
    {
        _locationManager.headingFilter = 5;
        [_locationManager startUpdatingHeading];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    self.locationLab.text = [NSString stringWithFormat:@"User Loc(%.5lf ,%.5lf)",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
}


#pragma mark - MapKit Delegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    
    NSLog(@"Coordinate:(%.6lf %.6lf)\n Map width:%.2lf x %.2lf",
          [_mapView region].center.latitude,
          [_mapView region].center.longitude,
          [_mapView region].span.latitudeDelta * 100000,
          [_mapView region].span.longitudeDelta * 100000);
    _centerPoint.coordinate = [_mapView region].center;
    self.finishPlace = [_mapView region].center;
    
}
-(MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id)overlay {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5;
    renderer.strokeColor = HEX_RGBA(0xf26f5f, 1);
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView* aView;
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        self.myPlace = annotation.coordinate;
        return nil;
    } else if([annotation isKindOfClass:[MyPinAnnotation class]]) {
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinAnnotation"];
        aView.canShowCallout = YES;
        aView.image = [UIImage imageNamed:@"pin"];
        aView.frame = CGRectMake(0, 0, 50, 50);
        UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
        myCustomImage.frame = CGRectMake(0, 0, 50, 50);
        aView.leftCalloutAccessoryView = myCustomImage;
        
        MapMarkBtn *rightButton = [[MapMarkBtn alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        rightButton.coordinate = annotation.coordinate;
        rightButton.backgroundColor = [UIColor grayColor];
        [rightButton setTitle:@"Goto" forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(gotoPlace:) forControlEvents:UIControlEventTouchUpInside];
        aView.rightCalloutAccessoryView = rightButton;
    }
    else  {
        
       
        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MKPointAnnotation"];
        aView.canShowCallout = YES;
        aView.image = [UIImage imageNamed:@"pin"];
        aView.frame = CGRectMake(0, 0, 50, 50);
       
        
    }
    return aView;
    
}
@end
