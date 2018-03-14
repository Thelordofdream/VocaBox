//
//  ViewController.m
//  VocaBox
//
//  Created by 张铭杰 on 2/11/17.
//  Copyright © 2017年 张铭杰. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>

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
    box.doubleAction = @selector(didDoubleClickFolderRow:);
    
    
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

- (IBAction)didDoubleClickFolderRow:(id)sender
{
    int row = (int)[box.selectedRowIndexes firstIndex];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"提醒"];
    [alert addButtonWithTitle:@"删除"];//添加按钮
    [alert addButtonWithTitle:@"取消"];
    [alert setInformativeText:[[@"是否删除词条 " stringByAppendingString:[keys objectAtIndex:row]] stringByAppendingString:@" ?"]];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn)
        {
            [dic removeObjectForKey:[keys objectAtIndex:row]];//第一个按钮被按下后执行
            keys = [[dic allKeys] sortedArrayUsingComparator:sort];
            [box reloadData];
            [dic writeToFile:fileDicPath atomically:YES];
            NSLog(@"removed");
        }
        if(returnCode == NSAlertSecondButtonReturn)
        {
            NSLog(@"canceled");//第二个按钮被按下后执行
        }
    }];
}

-(IBAction)store:(id)sender{
    NSString *w = [word.stringValue lowercaseStringWithLocale:[NSLocale currentLocale]];
    NSString *m = meaning.stringValue;
    if(![w  isEqual: @""] && ![m  isEqual: @""]){
        [dic setValue:m forKey:w];
        keys = [[dic allKeys] sortedArrayUsingComparator:sort];
        [box reloadData];
        [dic writeToFile:fileDicPath atomically:YES];
        word.stringValue = @"";
        meaning.stringValue = @"";
    }
    else{
        NSLog(@"content is empty");
        [box reloadData];
    }
}

-(IBAction)search:(id)sender{
    key = [keyword.stringValue lowercaseStringWithLocale:[NSLocale currentLocale]];
    if(![keyword  isEqual: @""]){
        if([key characterAtIndex:0] > 96 && [key characterAtIndex:0] < 123){
            NSString *r = [dic objectForKey:key];
            if(r != nil)
            {
                result.stringValue = r;
                source.stringValue = @"来自本地词典";
            }
            else
            {
                res = [self GetChinese:key];
                result.stringValue = res;
                source.stringValue = @"来自百度翻译";
            }
        }
        else
        {
            result.stringValue = @"目前仅支持英文查询";
            source.stringValue = @"";
        }
    }
    else
    {
        result.stringValue = @"请输入搜索关键词";
        source.stringValue = @"";
    }
}

-(IBAction)save:(id)sender{
    if(![key isEqual:@""] && ![res isEqual:@""])
    {
        if([dic objectForKey:key] == nil){
            [dic setValue:res forKey:key];
            keys = [[dic allKeys] sortedArrayUsingComparator:sort];
            [box reloadData];
            [dic writeToFile:fileDicPath atomically:YES];
            NSLog(@"saved");
            word.stringValue = key;
            meaning.stringValue = res;
        }
        else
            NSLog(@"word exists");
    }
}
    

- (NSString *) GetChinese:(NSString *) apple
{
    @autoreleasepool{
        url=@"https://api.fanyi.baidu.com/api/trans/vip/translate?q=";
        url=[url stringByAppendingString:[apple stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        url=[url stringByAppendingString:@"&from=en&to=zh&appid=20160219000012662&salt=1994111377&sign="];
        
        sign=[@"20160219000012662" stringByAppendingString:apple];
        sign=[sign stringByAppendingString:@"1994111377"];
        sign=[sign stringByAppendingString:@"iPCFWwPIxoDVfDIzQHoN"];
        const char *cStr = [sign UTF8String];
        unsigned char digest[16];
        CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
        NSMutableString *result = [NSMutableString stringWithCapacity:32];
        for(int k = 0; k < 16 ;k++)
            [result appendFormat:@"%2.2x",(int)digest[k]];
        
        url=[url stringByAppendingString:result];
        URL = [NSURL URLWithString:url];
        
        request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
        NSURLResponse *response = nil;
        NSError *error=nil;
        baidu = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        BAIDU = [NSJSONSerialization JSONObjectWithData:baidu options:0 error:&error];
        return BAIDU[@"trans_result"][0][@"dst"];
    }
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
