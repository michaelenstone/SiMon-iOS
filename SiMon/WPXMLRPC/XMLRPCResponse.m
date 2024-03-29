//
//  Cocoa XML-RPC Client Framework
//  XMLRPCConnection.m
//
//  Created by Eric J. Czarny on Thu Jan 15 2004.
//  Copyright (c) 2004 Divisible by Zero.
//

//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without 
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or 
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "XMLRPCResponse.h"
#import "WPXMLRPCDecoder.h"

@implementation XMLRPCResponse

- (id)initWithData: (NSData *)data
{
	if (data == nil)
	{
		return nil;
	}

	if (self = [super init])
	{
		WPXMLRPCDecoder *decoder = [[WPXMLRPCDecoder alloc] initWithData: data];
		
		if (decoder == nil)
		{
			return nil;
		}
	
		_data = [[NSData alloc] initWithData: data];
		_source = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
		_object = nil;
		
		if (decoder.isFault)
		{
            _isParseError = TRUE;
			NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Parse Error. Please check input values.", NSLocalizedDescriptionKey, nil];
			_object = [NSError errorWithDomain:@"come.effigent.iphone.parseerror" code:-1 userInfo:usrInfo];
		}
		else
		{
			_object = decoder.object;
		}
		
		_isFault = [decoder isFault];
	}
	
	return self;
}

#pragma mark -

- (BOOL)isFault
{
	return _isFault;
}

- (NSNumber *)code
{
	if (_isFault)
	{
		return [_object objectForKey: @"faultCode"];
	}
	
	return nil;
}

- (NSString *)fault
{
	if (_isFault)
	{
		return [_object objectForKey: @"faultString"];
	}
	
	return nil;
}

#pragma mark -

- (BOOL)isParseError
{
	return _isParseError;
}

#pragma mark -

- (id)object
{
	return _object;
}

#pragma mark -

- (NSString *)source
{
	return _source;
}

- (int64_t)length
{
	return [_data length];
}

@end