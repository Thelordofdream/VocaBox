//
//  ViewController.h
//  VocaBox
//
//  Created by 张铭杰 on 2/11/17.
//  Copyright © 2017年 张铭杰. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
{
    __weak IBOutlet NSTableView *box;
    __weak IBOutlet NSTextField *word;
    __weak IBOutlet NSTextField *meaning;
    __weak IBOutlet NSTextField *keyword;
    __weak IBOutlet NSTextField *result;
    __weak IBOutlet NSTextField *amount;
    NSString *fileDicPath;
    NSMutableDictionary *dic;
    NSArray *keys;
    NSComparator sort;
}
@end

