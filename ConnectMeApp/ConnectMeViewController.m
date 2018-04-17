//
//  FirstViewController.m
//  ConnectMeApp
//
//  Created by punit on 28/05/15.
//  Copyright (c) 2015 Parnit. All rights reserved.
//

#import "ConnectMeViewController.h"
#import "SoundLevelDetector.h"
#import "MCConnection.h"
#import "TextToSpeechConverter.h"
#import "MCController.h"
#import "IPUtils.h"
#import "PeerConnectionViewCell.h"
#import "SectionHeaderView.h"
#import "FileSharingViewController.h"

@interface ConnectMeViewController (){
  
  SoundLevelDetector *detector;
  TextToSpeechConverter *converter;
  
}
@property (nonatomic, strong) NSMutableDictionary *listOtherDevices;
@property (nonatomic, strong) NSMutableDictionary *listAppleDevices;

@property PeerFinder *peerFinder;

@end

@implementation ConnectMeViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
  
  self.navigationController.navigationBar.backgroundColor = [UIColor lightGrayColor];
  self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
  
  
  UIBarButtonItem *refreshBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startPeerScan)];
  self.navigationItem.rightBarButtonItem = refreshBarButton;
  
  
  //UIBarButtonItem *fileShareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fileShare)];
  self.navigationItem.leftBarButtonItem = self.fileShareButton;
  
  
  // Do any additional setup after loading the view, typically from a nib.
  detector=[[SoundLevelDetector alloc] init];
  converter=[[TextToSpeechConverter  alloc] init];
  
  [detector initMicBlow];
  
  [[MCController sharedChannelController] setConnectionDelegate:self];
  [self startPeerScan];
  
}

- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
  //[self.peerFinder stopScan];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if (motion == UIEventSubtypeMotionShake) {
    [self showAlert];
  }
}

-(void)showAlert
{
  NSString *msg= [NSString stringWithFormat:@"Help %@",[[UIDevice currentDevice] name] ];
  [[MCController sharedChannelController] sendMessageToAll:msg];
  
  //  UIAlertView *alertView = [[UIAlertView alloc]
  //                            initWithTitle:@"Shake Demo"
  //                            message:@"Shake Detected"
  //                            delegate:nil
  //                            cancelButtonTitle:@"OK"
  //                            otherButtonTitles:nil];
  //  [alertView show];
}

#pragma mark - incoming
-(void)connectedToUserWithID:(NSInteger)userID
{
  NSString *inStr = [NSString stringWithFormat:@"%ld", (long)userID];
  Device *device=[self.listAppleDevices objectForKey:inStr];
  if (device == nil) {
    NSLog(@"No device found with id %@",device);
    return;
  }
  
  device.isConnected=YES;
  [self.listAppleDevices setObject:device forKey:inStr];
  [self.tableView reloadData];
  //Add user to array
  // [_dataController addUserID:userID];
  NSLog(@"**********User connected with id %ld**********",(long)userID);
  //[_bar performSelectorOnMainThread:@selector(peerConnected) withObject:nil waitUntilDone:NO];
  
}

-(void)disconnectedFromUserWithID:(NSInteger)userID
{
  //Remove user
  //[_dataController removeUserID:userID];
  NSLog(@"**********User disconnected with id %ld**********",(long)userID);
  
  NSString *inStr = [NSString stringWithFormat:@"%ld", (long)userID];
  Device *device=[self.listAppleDevices objectForKey:inStr];
  if (device==nil) {
    return;
  }
  device.isConnected=NO;
  [self.listAppleDevices setObject:device forKey:inStr];
  [self.tableView reloadData ];
  
  //  [_bar performSelectorOnMainThread:@selector(peerDropped) withObject:nil waitUntilDone:NO];
  
}

-(void)connectingToUserWithID:(NSInteger)userID
{
  //[_bar performSelectorOnMainThread:@selector(peerConnecting) withObject:nil waitUntilDone:NO];
}

-(void)startingToSearch{
  //[_bar performSelectorOnMainThread:@selector(startedSearchingForPeers) withObject:nil waitUntilDone:NO];
}

-(void)userWithID:(NSInteger)userID didReceiveMessage:(NSString*)morse withName:(NSString *)deviceName
{
  NSLog(@"UPDATE USER '%li' with data '%@' , %@ ",(long)userID, morse,deviceName);
  dispatch_async(dispatch_get_main_queue(), ^{
    [converter createSoundForText:morse ];
    
    NSLog(@"Generating local notification");
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    // NSString *bodyStr = [NSString stringWithFormat:@"ConnectMe Alert!"];
    localNotification.alertBody = deviceName;
    localNotification.alertAction = morse;
    //On sound
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectMeAlert" object:nil];
    
  });
}

-(void)userWithID:(NSInteger)userID didSendLetter:(NSString*)letter
{
  
  
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  
  if (section==0) {
    return [[self.listAppleDevices allKeys] count];
  }else if (section==1){
    return [[self.listOtherDevices allKeys] count];
  }else{
    return 0;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  PeerConnectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  Device *device=nil;
  
  if (indexPath.section==0) {
    device = [[self.listAppleDevices allValues] objectAtIndex:indexPath.row];
  }else if(indexPath.section==1){
    device = [[self.listOtherDevices allValues] objectAtIndex:indexPath.row];
    
  }
  if (device==nil) {
    return nil;
  }
  
  cell.textLabel.text = device.name;
  cell.detailTextLabel.text = device.macAddress;
  if (device.isAppleDevice) {
    if (device.isConnected) {
      [cell setBackgroundColor:[UIColor greenColor]];
      
    }else{
      [cell setBackgroundColor:[UIColor yellowColor]];
    }
    
    [[cell subscribe] setHidden:NO];
    //@@@ add switch value
    
  }else{
    [cell setBackgroundColor:[UIColor whiteColor]];
    [[cell subscribe] setHidden:YES];
  }
  
  return cell;
}


//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//
//  SectionHeaderView *header=[tableView dequeueReusableCellWithIdentifier:@"SectionHeaderView"];
//  if (section==0) {
//    header.titleLabel.text=[NSString stringWithFormat:@"Apple Devices"];
//  }else{
//    header.titleLabel.text=[NSString stringWithFormat:@"Other Devices "];
//
//  }
//  return [header view];
//}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  
  // 1. The view for the header
  UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
  
  // 2. Set a custom background color and a border
  //headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"section_header.png"]];

  headerView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
  headerView.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
  headerView.layer.borderWidth = 1.0;
  
  // 3. Add a label
  UILabel* headerLabel = [[UILabel alloc] init];
  headerLabel.frame = CGRectMake(5, 2, tableView.frame.size.width - 5, 18);
  headerLabel.backgroundColor = [UIColor clearColor];
  headerLabel.textColor = [UIColor whiteColor];
  headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
  headerLabel.textAlignment = NSTextAlignmentLeft;
  
  if (section==0){
    headerLabel.text = @"Apple Devices";
  }else{
    headerLabel.text = @"Other Devices";
    
  }
  
  // 4. Add the label to the header view
  [headerView addSubview:headerLabel];
  // 5. Finally return
  return headerView;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 40;
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */
#pragma mark MCController delegate method
-(void)foundNewPeer:(NSString *)peerID :(NSInteger)userID{
  NSLog(@"found  %@", peerID);
  Device *device = [[Device alloc] init];
  device.name = peerID;
  device.address = peerID;
  device.isAppleDevice=YES;
  //device.macAddress=  [IPUtils ipToMac:address];
  NSString *inStr = [NSString stringWithFormat:@"%ld", (long)userID];
  NSLog(@"user id for device found %@",inStr);
  for (Device *device in [self.listAppleDevices allValues]) {
    if ([device.name isEqualToString:peerID]) {
      NSLog(@"Device %@ Already exist ignoring ",peerID);
      return;
    }
  }
  [self.listAppleDevices setObject:device forKey:inStr];
  [self.tableView reloadData];
}


#pragma mark LAN Scanner delegate method
- (void)scanLANDidFindNewAdrress:(NSString *)address havingHostName:(NSString *)hostName {
  NSLog(@"found  %@", address);
  Device *device = [[Device alloc] init];
  device.name = hostName;
  device.address = address;
  device.macAddress=  [IPUtils ipToMac:address];
  NSLog(@"Mac address %@",device.macAddress);
  [self.listOtherDevices setObject:device forKey:hostName];
  [self.tableView reloadData];
}

- (void)scanLANDidFinishScanning {
  NSLog(@"Scan finished");
  //  [[[UIAlertView alloc] initWithTitle:@"Scan Finished" message:[NSString stringWithFormat:@"Number of devices connected to the Local Area Network : %d", self.lanConnectedDevices.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}


- (void)startPeerScan {
  
  self.listAppleDevices=nil;
  self.listOtherDevices=nil;
  
  [self.tableView reloadData ];
  [[MCController sharedChannelController] disconnect];
  [self.peerFinder stopScan];
  
  [[MCController sharedChannelController] connect];
  self.listAppleDevices=[[NSMutableDictionary alloc] init];
  self.listOtherDevices=[[NSMutableDictionary alloc] init];
  self.peerFinder = [[PeerFinder alloc] initWithDelegate:self];
  [self.peerFinder startScan];
}




@end
