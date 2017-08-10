//
//	CKLiveStream.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "CKLiveStream.h"

NSString *const kCKLiveStreamDmError = @"dm_error";
NSString *const kCKLiveStreamErrorMsg = @"error_msg";
NSString *const kCKLiveStreamExpireTime = @"expire_time";
NSString *const kCKLiveStreamLives = @"lives";

@interface CKLiveStream ()
@end
@implementation CKLiveStream




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kCKLiveStreamDmError] isKindOfClass:[NSNull class]]){
		self.dmError = [dictionary[kCKLiveStreamDmError] integerValue];
	}

	if(![dictionary[kCKLiveStreamErrorMsg] isKindOfClass:[NSNull class]]){
		self.errorMsg = dictionary[kCKLiveStreamErrorMsg];
	}	
	if(![dictionary[kCKLiveStreamExpireTime] isKindOfClass:[NSNull class]]){
		self.expireTime = [dictionary[kCKLiveStreamExpireTime] integerValue];
	}

	if(dictionary[kCKLiveStreamLives] != nil && [dictionary[kCKLiveStreamLives] isKindOfClass:[NSArray class]]){
		NSArray * livesDictionaries = dictionary[kCKLiveStreamLives];
		NSMutableArray * livesItems = [NSMutableArray array];
		for(NSDictionary * livesDictionary in livesDictionaries){
			CKLive * livesItem = [[CKLive alloc] initWithDictionary:livesDictionary];
			[livesItems addObject:livesItem];
		}
		self.lives = livesItems;
	}
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kCKLiveStreamDmError] = @(self.dmError);
	if(self.errorMsg != nil){
		dictionary[kCKLiveStreamErrorMsg] = self.errorMsg;
	}
	dictionary[kCKLiveStreamExpireTime] = @(self.expireTime);
	if(self.lives != nil){
		NSMutableArray * dictionaryElements = [NSMutableArray array];
		for(CKLive * livesElement in self.lives){
			[dictionaryElements addObject:[livesElement toDictionary]];
		}
		dictionary[kCKLiveStreamLives] = dictionaryElements;
	}
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:@(self.dmError) forKey:kCKLiveStreamDmError];	if(self.errorMsg != nil){
		[aCoder encodeObject:self.errorMsg forKey:kCKLiveStreamErrorMsg];
	}
	[aCoder encodeObject:@(self.expireTime) forKey:kCKLiveStreamExpireTime];	if(self.lives != nil){
		[aCoder encodeObject:self.lives forKey:kCKLiveStreamLives];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.dmError = [[aDecoder decodeObjectForKey:kCKLiveStreamDmError] integerValue];
	self.errorMsg = [aDecoder decodeObjectForKey:kCKLiveStreamErrorMsg];
	self.expireTime = [[aDecoder decodeObjectForKey:kCKLiveStreamExpireTime] integerValue];
	self.lives = [aDecoder decodeObjectForKey:kCKLiveStreamLives];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	CKLiveStream *copy = [CKLiveStream new];

	copy.dmError = self.dmError;
	copy.errorMsg = [self.errorMsg copy];
	copy.expireTime = self.expireTime;
	copy.lives = [self.lives copy];

	return copy;
}
@end