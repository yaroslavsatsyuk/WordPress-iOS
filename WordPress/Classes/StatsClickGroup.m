//
//  StatClickGroup.m
//  WordPress
//
//  Created by DX074-XL on 2014-01-06.
//  Copyright (c) 2014 WordPress. All rights reserved.
//

#import "StatsClickGroup.h"
#import "StatsClick.h"

@implementation StatsClickGroup


+(NSArray *)clickGroupsFromData:(NSDictionary *)clickGroups withSiteId:(NSNumber *)siteId {
    NSDictionary *clicks = clickGroups[@"clicks"];
    NSMutableArray *clickGroupList = [NSMutableArray array];
    for (NSDictionary *clickGroup in clicks) {
        StatsClickGroup *cg = [[StatsClickGroup alloc] init];
        cg.group = clickGroup[@"group"];
        cg.title = clickGroup[@"name"];
        if (clickGroup[@"icon"] != [NSNull null]) {
            cg.iconUrl = [NSURL URLWithString:clickGroup[@"icon"]];
        }
        cg.count = clickGroup[@"total"];;
        cg.siteId = siteId;
        cg.clicks = [StatsClick clicksFromArray:clickGroup[@"results"] siteId:siteId];
        [clickGroupList addObject:cg];
    }
    return clickGroupList;
}

@end
