//
//  ViewController.m
//  PhotographEnlarged
//
//  Created by work on 2020/10/13.
//  Copyright © 2020 苏. All rights reserved.
//

#import "ViewController.h"
#import "TransImageTool.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (nonatomic, strong)  TransImageTool *imageTool;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
}
- (IBAction)imageTap:(UITapGestureRecognizer *)sender
{
    NSLog(@"test");

    TransImageTool *enlargeTool = [[TransImageTool alloc] init];
    self.imageTool = enlargeTool;
    [enlargeTool showImage:self.showImageView];
}


@end
