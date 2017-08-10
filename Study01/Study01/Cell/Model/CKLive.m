//
//	CKLive.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "CKLive.h"

NSString *const kCKLiveCity = @"city";
NSString *const kCKLiveCreator = @"creator";
NSString *const kCKLiveExtra = @"extra";
NSString *const kCKLiveGroup = @"group";
NSString *const kCKLiveIdField = @"id";
NSString *const kCKLiveImage = @"image";
NSString *const kCKLiveLandscape = @"landscape";
NSString *const kCKLiveLike = @"like";
NSString *const kCKLiveLink = @"link";
NSString *const kCKLiveLiveType = @"live_type";
NSString *const kCKLiveMulti = @"multi";
NSString *const kCKLiveName = @"name";
NSString *const kCKLiveOnlineUsers = @"online_users";
NSString *const kCKLiveOptimal = @"optimal";
NSString *const kCKLivePubStat = @"pub_stat";
NSString *const kCKLiveRoomId = @"room_id";
NSString *const kCKLiveRotate = @"rotate";
NSString *const kCKLiveShareAddr = @"share_addr";
NSString *const kCKLiveSlot = @"slot";
NSString *const kCKLiveStatus = @"status";
NSString *const kCKLiveStreamAddr = @"stream_addr";
NSString *const kCKLiveTagId = @"tag_id";
NSString *const kCKLiveToken = @"token";
NSString *const kCKLiveVersion = @"version";

@interface CKLive ()
@end
@implementation CKLive




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kCKLiveCity] isKindOfClass:[NSNull class]]){
		self.city = dictionary[kCKLiveCity];
	}	
	if(![dictionary[kCKLiveCreator] isKindOfClass:[NSNull class]]){
		self.creator = [[CKCreator alloc] initWithDictionary:dictionary[kCKLiveCreator]];
	}

	if(![dictionary[kCKLiveExtra] isKindOfClass:[NSNull class]]){
		self.extra = [[CKExtra alloc] initWithDictionary:dictionary[kCKLiveExtra]];
	}

	if(![dictionary[kCKLiveGroup] isKindOfClass:[NSNull class]]){
		self.group = [dictionary[kCKLiveGroup] integerValue];
	}

	if(![dictionary[kCKLiveIdField] isKindOfClass:[NSNull class]]){
		self.idField = dictionary[kCKLiveIdField];
	}	
	if(![dictionary[kCKLiveImage] isKindOfClass:[NSNull class]]){
		self.image = dictionary[kCKLiveImage];
	}	
	if(![dictionary[kCKLiveLandscape] isKindOfClass:[NSNull class]]){
		self.landscape = [dictionary[kCKLiveLandscape] integerValue];
	}

	if(![dictionary[kCKLiveLike] isKindOfClass:[NSNull class]]){
		self.like = dictionary[kCKLiveLike];
	}	
	if(![dictionary[kCKLiveLink] isKindOfClass:[NSNull class]]){
		self.link = [dictionary[kCKLiveLink] integerValue];
	}

	if(![dictionary[kCKLiveLiveType] isKindOfClass:[NSNull class]]){
		self.liveType = dictionary[kCKLiveLiveType];
	}	
	if(![dictionary[kCKLiveMulti] isKindOfClass:[NSNull class]]){
		self.multi = [dictionary[kCKLiveMulti] integerValue];
	}

	if(![dictionary[kCKLiveName] isKindOfClass:[NSNull class]]){
		self.name = dictionary[kCKLiveName];
	}	
	if(![dictionary[kCKLiveOnlineUsers] isKindOfClass:[NSNull class]]){
		self.onlineUsers = [dictionary[kCKLiveOnlineUsers] integerValue];
	}

	if(![dictionary[kCKLiveOptimal] isKindOfClass:[NSNull class]]){
		self.optimal = [dictionary[kCKLiveOptimal] integerValue];
	}

	if(![dictionary[kCKLivePubStat] isKindOfClass:[NSNull class]]){
		self.pubStat = [dictionary[kCKLivePubStat] integerValue];
	}

	if(![dictionary[kCKLiveRoomId] isKindOfClass:[NSNull class]]){
		self.roomId = [dictionary[kCKLiveRoomId] integerValue];
	}

	if(![dictionary[kCKLiveRotate] isKindOfClass:[NSNull class]]){
		self.rotate = [dictionary[kCKLiveRotate] integerValue];
	}

	if(![dictionary[kCKLiveShareAddr] isKindOfClass:[NSNull class]]){
		self.shareAddr = dictionary[kCKLiveShareAddr];
	}	
	if(![dictionary[kCKLiveSlot] isKindOfClass:[NSNull class]]){
		self.slot = [dictionary[kCKLiveSlot] integerValue];
	}

	if(![dictionary[kCKLiveStatus] isKindOfClass:[NSNull class]]){
		self.status = [dictionary[kCKLiveStatus] integerValue];
	}

	if(![dictionary[kCKLiveStreamAddr] isKindOfClass:[NSNull class]]){
		self.streamAddr = dictionary[kCKLiveStreamAddr];
	}	
	if(![dictionary[kCKLiveTagId] isKindOfClass:[NSNull class]]){
		self.tagId = dictionary[kCKLiveTagId];
	}	
	if(![dictionary[kCKLiveToken] isKindOfClass:[NSNull class]]){
		self.token = dictionary[kCKLiveToken];
	}	
	if(![dictionary[kCKLiveVersion] isKindOfClass:[NSNull class]]){
		self.version = [dictionary[kCKLiveVersion] integerValue];
	}

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.city != nil){
		dictionary[kCKLiveCity] = self.city;
	}
	if(self.creator != nil){
		dictionary[kCKLiveCreator] = [self.creator toDictionary];
	}
	if(self.extra != nil){
		dictionary[kCKLiveExtra] = [self.extra toDictionary];
	}
	dictionary[kCKLiveGroup] = @(self.group);
	if(self.idField != nil){
		dictionary[kCKLiveIdField] = self.idField;
	}
	if(self.image != nil){
		dictionary[kCKLiveImage] = self.image;
	}
	dictionary[kCKLiveLandscape] = @(self.landscape);
	if(self.like != nil){
		dictionary[kCKLiveLike] = self.like;
	}
	dictionary[kCKLiveLink] = @(self.link);
	if(self.liveType != nil){
		dictionary[kCKLiveLiveType] = self.liveType;
	}
	dictionary[kCKLiveMulti] = @(self.multi);
	if(self.name != nil){
		dictionary[kCKLiveName] = self.name;
	}
	dictionary[kCKLiveOnlineUsers] = @(self.onlineUsers);
	dictionary[kCKLiveOptimal] = @(self.optimal);
	dictionary[kCKLivePubStat] = @(self.pubStat);
	dictionary[kCKLiveRoomId] = @(self.roomId);
	dictionary[kCKLiveRotate] = @(self.rotate);
	if(self.shareAddr != nil){
		dictionary[kCKLiveShareAddr] = self.shareAddr;
	}
	dictionary[kCKLiveSlot] = @(self.slot);
	dictionary[kCKLiveStatus] = @(self.status);
	if(self.streamAddr != nil){
		dictionary[kCKLiveStreamAddr] = self.streamAddr;
	}
	if(self.tagId != nil){
		dictionary[kCKLiveTagId] = self.tagId;
	}
	if(self.token != nil){
		dictionary[kCKLiveToken] = self.token;
	}
	dictionary[kCKLiveVersion] = @(self.version);
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
	if(self.city != nil){
		[aCoder encodeObject:self.city forKey:kCKLiveCity];
	}
	if(self.creator != nil){
		[aCoder encodeObject:self.creator forKey:kCKLiveCreator];
	}
	if(self.extra != nil){
		[aCoder encodeObject:self.extra forKey:kCKLiveExtra];
	}
	[aCoder encodeObject:@(self.group) forKey:kCKLiveGroup];	if(self.idField != nil){
		[aCoder encodeObject:self.idField forKey:kCKLiveIdField];
	}
	if(self.image != nil){
		[aCoder encodeObject:self.image forKey:kCKLiveImage];
	}
	[aCoder encodeObject:@(self.landscape) forKey:kCKLiveLandscape];	if(self.like != nil){
		[aCoder encodeObject:self.like forKey:kCKLiveLike];
	}
	[aCoder encodeObject:@(self.link) forKey:kCKLiveLink];	if(self.liveType != nil){
		[aCoder encodeObject:self.liveType forKey:kCKLiveLiveType];
	}
	[aCoder encodeObject:@(self.multi) forKey:kCKLiveMulti];	if(self.name != nil){
		[aCoder encodeObject:self.name forKey:kCKLiveName];
	}
	[aCoder encodeObject:@(self.onlineUsers) forKey:kCKLiveOnlineUsers];	[aCoder encodeObject:@(self.optimal) forKey:kCKLiveOptimal];	[aCoder encodeObject:@(self.pubStat) forKey:kCKLivePubStat];	[aCoder encodeObject:@(self.roomId) forKey:kCKLiveRoomId];	[aCoder encodeObject:@(self.rotate) forKey:kCKLiveRotate];	if(self.shareAddr != nil){
		[aCoder encodeObject:self.shareAddr forKey:kCKLiveShareAddr];
	}
	[aCoder encodeObject:@(self.slot) forKey:kCKLiveSlot];	[aCoder encodeObject:@(self.status) forKey:kCKLiveStatus];	if(self.streamAddr != nil){
		[aCoder encodeObject:self.streamAddr forKey:kCKLiveStreamAddr];
	}
	if(self.tagId != nil){
		[aCoder encodeObject:self.tagId forKey:kCKLiveTagId];
	}
	if(self.token != nil){
		[aCoder encodeObject:self.token forKey:kCKLiveToken];
	}
	[aCoder encodeObject:@(self.version) forKey:kCKLiveVersion];
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.city = [aDecoder decodeObjectForKey:kCKLiveCity];
	self.creator = [aDecoder decodeObjectForKey:kCKLiveCreator];
	self.extra = [aDecoder decodeObjectForKey:kCKLiveExtra];
	self.group = [[aDecoder decodeObjectForKey:kCKLiveGroup] integerValue];
	self.idField = [aDecoder decodeObjectForKey:kCKLiveIdField];
	self.image = [aDecoder decodeObjectForKey:kCKLiveImage];
	self.landscape = [[aDecoder decodeObjectForKey:kCKLiveLandscape] integerValue];
	self.like = [aDecoder decodeObjectForKey:kCKLiveLike];
	self.link = [[aDecoder decodeObjectForKey:kCKLiveLink] integerValue];
	self.liveType = [aDecoder decodeObjectForKey:kCKLiveLiveType];
	self.multi = [[aDecoder decodeObjectForKey:kCKLiveMulti] integerValue];
	self.name = [aDecoder decodeObjectForKey:kCKLiveName];
	self.onlineUsers = [[aDecoder decodeObjectForKey:kCKLiveOnlineUsers] integerValue];
	self.optimal = [[aDecoder decodeObjectForKey:kCKLiveOptimal] integerValue];
	self.pubStat = [[aDecoder decodeObjectForKey:kCKLivePubStat] integerValue];
	self.roomId = [[aDecoder decodeObjectForKey:kCKLiveRoomId] integerValue];
	self.rotate = [[aDecoder decodeObjectForKey:kCKLiveRotate] integerValue];
	self.shareAddr = [aDecoder decodeObjectForKey:kCKLiveShareAddr];
	self.slot = [[aDecoder decodeObjectForKey:kCKLiveSlot] integerValue];
	self.status = [[aDecoder decodeObjectForKey:kCKLiveStatus] integerValue];
	self.streamAddr = [aDecoder decodeObjectForKey:kCKLiveStreamAddr];
	self.tagId = [aDecoder decodeObjectForKey:kCKLiveTagId];
	self.token = [aDecoder decodeObjectForKey:kCKLiveToken];
	self.version = [[aDecoder decodeObjectForKey:kCKLiveVersion] integerValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	CKLive *copy = [CKLive new];

	copy.city = [self.city copy];
	copy.creator = [self.creator copy];
	copy.extra = [self.extra copy];
	copy.group = self.group;
	copy.idField = [self.idField copy];
	copy.image = [self.image copy];
	copy.landscape = self.landscape;
	copy.like = [self.like copy];
	copy.link = self.link;
	copy.liveType = [self.liveType copy];
	copy.multi = self.multi;
	copy.name = [self.name copy];
	copy.onlineUsers = self.onlineUsers;
	copy.optimal = self.optimal;
	copy.pubStat = self.pubStat;
	copy.roomId = self.roomId;
	copy.rotate = self.rotate;
	copy.shareAddr = [self.shareAddr copy];
	copy.slot = self.slot;
	copy.status = self.status;
	copy.streamAddr = [self.streamAddr copy];
	copy.tagId = [self.tagId copy];
	copy.token = [self.token copy];
	copy.version = self.version;

	return copy;
}
@end
