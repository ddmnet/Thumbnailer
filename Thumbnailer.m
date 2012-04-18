#import "Thumbnailer.h" 
#import "UIImage+Resize.h"

//Default compression of JPEG images
#define kJPEGCompressionQuality 0.8

@implementation Thumbnailer 

@synthesize callbackID;

- (PGPlugin *)initWithWebView:(UIWebView*)theWebView{
    self = (Thumbnailer *)[super initWithWebView:theWebView];
    if(self){
        //Declare the location of the processed images
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        imageCacheDirectory = [[cacheDirectory stringByAppendingPathComponent:@"thumbnailer_image_cache"] retain];
    }
    return self;
}

//Scale an image to a specified width and save its contents in a Library/Caches subdirectory
-(void)scale:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{   
	//The first argument in the arguments parameter is the callbackID.
	//We use this to send data back to the successCallback or failureCallback
	//through PluginResult.   
	self.callbackID = [arguments pop];
    
	//Obtain parameters 
    NSString *sourcePath = [arguments objectAtIndex:0];
    NSNumber *pxWide = [arguments objectAtIndex:1];
    BOOL shouldOverwrite = [[arguments objectAtIndex:2] boolValue];
    
    //Calculate variables
    NSString *type = [[sourcePath pathExtension] lowercaseString];
    NSString *filename = [sourcePath lastPathComponent];
    NSString *destinationPath = [imageCacheDirectory stringByAppendingPathComponent:filename];
    
    //Generate unique filename if needed
    if(!shouldOverwrite){
        destinationPath = [self ensureUniqueFilenameForPath:destinationPath];
    }
    
    //Create scaled_images directory if it doesn't exist
    if(![[NSFileManager defaultManager] createDirectoryAtPath:imageCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]){
        NSLog(@"Unable to create scaled_images directory");
        [self fail];
        return;
    }
    
    //Load source image
    UIImage *sourceImage = [UIImage imageWithContentsOfFile:sourcePath];
    
    //Fail if source image can't be found
    if(!sourceImage){
        NSLog(@"Source image not found");
        [self fail];
        return;
    }
    
    //Scale source image
    CGSize newSize = CGSizeMake(pxWide.floatValue, pxWide.floatValue*(sourceImage.size.height/sourceImage.size.width));
    UIImage *scaledImage = [sourceImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:newSize interpolationQuality:kCGInterpolationDefault];

    //Create jpg or png
    NSData *scaledImageData;
    if([type isEqualToString:@"png"]){
        scaledImageData = UIImagePNGRepresentation(scaledImage);
    }
    else{
        scaledImageData = UIImageJPEGRepresentation(scaledImage, kJPEGCompressionQuality);
    }
    
    //Fail if jpg or png creation experienced an error
    if(!scaledImageData){
        NSLog(@"Problem encountered copying the image");
        [self fail];
        return;        
    }
    
    //Write scaled image to file, fail on error
    if(![scaledImageData writeToFile:destinationPath atomically:YES]){
        NSLog(@"Unable to write file to disk");
        [self fail];
        return;
    };
    
	//Create Plugin Result for success
	PluginResult *pluginResult;
    pluginResult = [PluginResult resultWithStatus:PGCommandStatus_OK messageAsString: destinationPath];
    [self writeJavascript: [pluginResult toSuccessCallbackString:self.callbackID]];    
}

//Clear the entire image cache directory
-(void)deleteAllImages:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    if(![[NSFileManager defaultManager] removeItemAtPath:imageCacheDirectory error:nil]){
        NSLog(@"Unable to delete the image cache directory");
    }
}

//Send the result of false to the errorCallbackFunction
-(void)fail
{
    //Create Plugin Result for failure
	NSString *resultString = false;
	PluginResult *pluginResult = [PluginResult resultWithStatus:PGCommandStatus_ERROR messageAsString: [resultString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [self writeJavascript: [pluginResult toErrorCallbackString:self.callbackID]];
}

//Generate unique filename if file already exists
-(NSString *)ensureUniqueFilenameForPath:(NSString *)path {
    NSString *containingDirectory = [path stringByDeletingLastPathComponent];
    NSString *originalName = [path lastPathComponent];
    NSUInteger counter = 0;
    
    NSString *appendedPath = path;
    NSString *filename;
    NSString *extension;
    BOOL isDirectory;
    
    while ([[NSFileManager defaultManager] fileExistsAtPath:appendedPath isDirectory:&isDirectory]){
        counter++;
        filename = isDirectory ? originalName : [originalName stringByDeletingPathExtension];
        extension = isDirectory ? @"" : [NSString stringWithFormat:@".%@",[path pathExtension]];
        appendedPath = [NSString stringWithFormat:@"%@/%@-%u%@",containingDirectory,filename,counter,extension];        
    }

    return appendedPath;
}

-(void)dealloc
{
    imageCacheDirectory = nil;
    [imageCacheDirectory release];
    
    [super dealloc];
}

@end