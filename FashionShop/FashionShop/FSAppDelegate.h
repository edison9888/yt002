//
//  FSAppDelegate.h
//  FashionShop
//
//  Created by gong yi on 11/2/12.
//  Copyright (c) 2012 Fashion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSLocationManager.h"
#import "FSModelManager.h"
#import "CL_VoiceEngine.h"

@class PKRevealController;

@interface FSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) FSModelManager *modelManager;

@property (strong,nonatomic) FSLocationManager *locationManager;

@property (strong,nonatomic) NSMutableArray *allBrands;
@property (strong,nonatomic) CL_AudioRecorder* audioRecoder;
@property (strong,nonatomic) AVAudioPlayer *audioPlayer;

@property (strong,nonatomic) UIViewController *root;

@property (nonatomic, strong, readwrite) PKRevealController *revealController;

+(FSAppDelegate *)app;
-(void)entryMain;
-(void)initAudioRecoder;

-(BOOL)writeFile:(NSString*)aString fileName:(NSString*)aFileName;
-(NSString*)readFromFile:(NSString *)aFileName;

@end
