#import <Foundation/Foundation.h>
#import <PhoneGap/PGPlugin.h>
  
@interface Thumbnailer : PGPlugin {  
    NSString *callbackID;  
    NSString *imageCacheDirectory;
}

@property (nonatomic, copy) NSString *callbackID;

-(void)scale:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
-(void)deleteAllImages:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
-(void)fail;
-(NSString *)ensureUniqueFilenameForPath:(NSString *)path;

@end
