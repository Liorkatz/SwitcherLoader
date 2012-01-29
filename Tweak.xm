#import "SwitcherLoader.h"
#import <SpringBoard5.0/SBAppSwitcherBarView.h>
@interface UIView  (SwitcherLoader)
-(void)viewWillAppear;
-(void)viewWillDisappear;

@end
BOOL firstLoaded = YES;

SwitcherLoader *switcherLoader;

%hook SBAppSwitcherBarView
- (void)addAuxiliaryViews:(NSArray *)arg1 {
    [switcherLoader loadItems];
    if([[switcherLoader defaultViews]count] < 1) {
        [[switcherLoader defaultViews]addObjectsFromArray:arg1];
        
           }
   
    NSMutableArray *plugins = [NSMutableArray array];
    NSMutableArray *indexed = [switcherLoader enabledPluginsIndexed];
  
    for(unsigned int i =0; i <[indexed count]; i++) {
        NSString *pid = [indexed objectAtIndex:i];
        if([switcherLoader viewForId:pid])
        [plugins addObject:[switcherLoader viewForId:pid]];
               
    }
   
    [switcherLoader setStatus:Normal];
  
    %orig(plugins);
    if(firstLoaded) {
        NSMutableArray *views = MSHookIvar<NSMutableArray *>(self,"_auxViews");
        for(UIView *view in views) {
            if([view respondsToSelector:@selector(viewWillAppear)])
                [view viewWillAppear];
            
        } 
    }
    firstLoaded = NO;
}

- (void)viewWillAppear {
    
  if(switcherLoader.currentStatus == Update && !firstLoaded)
    [self addAuxiliaryViews:nil];
    %orig;
   
    
}


%end
%hook SBAppSwitcherController
- (void)viewWillAppear {
    %orig;
    NSMutableArray *views = MSHookIvar<NSMutableArray *>([self view],"_auxViews");
    for(UIView *view in views) {
        if([view respondsToSelector:@selector(viewWillAppear)])
            [view viewWillAppear];
        
    }    
}
- (void)viewWillDisappear {
    %orig;
    NSMutableArray *views = MSHookIvar<NSMutableArray *>([self view],"_auxViews");
    for(UIView *view in views) {
        if([view respondsToSelector:@selector(viewWillDisappear)])
            [view viewWillDisappear];
        
    }
    
}

%end
%hook SBNowPlayingBarView
%new
-(NSString *)plugin_id {
    
    return @"springboard.sbnowplayingbarview";
}
%end
%hook SBAirPlayBarView
%new
-(NSString *)plugin_id {
    
    return @"springboard.sbairplaybarview";
}
%end
%ctor {
   switcherLoader = [[SwitcherLoader alloc]init];
    
}