//
//  ViewController.m
//  VocaBox
//
//  Created by 张铭杰 on 2/11/17.
//  Copyright © 2017年 张铭杰. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSStringCompareOptions comparisonOptions = NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    sort = ^(NSString *obj1,NSString *obj2){
        NSRange range = NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    
    box.dataSource = self;
    box.delegate = self;
    
    
    // get the path of Documents
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // create the store path of the dictionary
    fileDicPath = [docPath stringByAppendingPathComponent:@"dictionary.txt"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if([fm fileExistsAtPath:fileDicPath]){
        NSLog(@"File exists");
    }
    else{
        // if file doesn't exist, creat a empty file
        NSLog(@"File doesn't exist");
        word.stringValue = @"naive";
        meaning.stringValue = @"幼稚的，天真的";
        dic = [NSMutableDictionary dictionary];
        [dic writeToFile:fileDicPath atomically:YES];
    }
    
    // read the dictionary from the file
    dic = [NSMutableDictionary dictionaryWithContentsOfFile:fileDicPath];
    keys = [[dic allKeys] sortedArrayUsingComparator:sort];
    
    // update the box
    [box reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    amount.stringValue = [[NSString stringWithFormat:@"%lu",(unsigned long)dic.count] stringByAppendingString:@" 词"];
    return dic.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([tableColumn.identifier isEqual: @"word"]){
        return [keys objectAtIndex:row];
    }
    else if([tableColumn.identifier isEqual: @"meaning"]){
        return [dic objectForKey:[keys objectAtIndex:row]];
    }
    return @"N/A";
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (void)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    word.stringValue = [keys objectAtIndex:row];
    meaning.stringValue = [dic objectForKey:[keys objectAtIndex:row]];
}

- (void)double_selected:(id)sender
{
    NSLog(@"Hello");
}

-(IBAction)store:(id)sender{
    NSString *w = [word.stringValue lowercaseStringWithLocale:[NSLocale currentLocale]];
    NSString *m = meaning.stringValue;
    if(w != nil && m !=nil){
        [dic setValue:m forKey:w];
        keys = [[dic allKeys] sortedArrayUsingComparator:sort];
        [box reloadData];
        [dic writeToFile:fileDicPath atomically:YES];
    }
    else{
        NSLog(@"Content is empty");
        [box reloadData];
    }
}

-(IBAction)search:(id)sender{
    NSString *k = [keyword.stringValue lowercaseStringWithLocale:[NSLocale currentLocale]];
    if(k != nil){
        if([k characterAtIndex:0] > 96 && [k characterAtIndex:0] < 123){
            NSString *r = [dic objectForKey:k];
            if(r != nil)
                result.stringValue = r;
            else
                result.stringValue = @"该单词不在词典中";
        }
        else
            result.stringValue = @"目前仅支持英文查询";
    }
    else
        result.stringValue = @"请输入搜索关键词";
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
