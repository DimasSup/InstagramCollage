//
//  CollageLayoutsHelper.m
//  SSS
//
//  Created by DimasSup on 24.04.14.
//  Copyright (c) 2014 DimasSup. All rights reserved.
//

#import "CollageLayoutsHelper.h"


@implementation CollageLayoutsHelper
+(NSArray *)newGetLayout:(int)imagesCount
{
	NSMutableArray* result =  [NSMutableArray new];
	switch (imagesCount) {
		case 1:
		{
			[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)]];
		}
			break;
		case 2:
		{
			if(random()%2 ==0)
			{
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 1, 0.4f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.4f, 1, 0.6f)]];
			}
			else
			{
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 1, 0.5f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.5f, 1, 0.5f)]];
			}
		}
			break;
		case 3:
		{
			if(random()%2 ==0)
			{
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 1, 0.4f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.4f, 0.4f, 0.6f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0.4f, 0.4f, 0.6f, 0.6f)]];
			}
			else
			{
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.4f, 1, 0.6f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 0.4f, 0.4f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0.4f, 0, 0.6f, 0.4f)]];
			}
		}
			break;
		case 4:
		{
			
			[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 0.6f, 0.4f)]];
			[result addObject:[NSValue valueWithCGRect:CGRectMake(0.6f, 0, 0.4f, 0.6f)]];
			[result addObject:[NSValue valueWithCGRect:CGRectMake(0.6f, 0.6f, 0.4f, 0.4f)]];
			[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.4f, 0.6f, 0.6f)]];
			

			
			
		}
			break;
		case 5:
		{
			if(random()%2 ==0)
			{
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 0.4f, 0.4f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.4f, 0.4f, 0.3f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.7f, 0.4f, 0.3f)]];
				
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0.4f, 0, 0.6f, 0.5f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0.4f, 0.5, 0.6f, 0.5f)]];
			}
			else
			{
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 0.25f, 0.3f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0.25f, 0, 0.25f, 0.3f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.3f, 0.5f, 0.3f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0, 0.6f, 1, 0.4f)]];
				[result addObject:[NSValue valueWithCGRect:CGRectMake(0.5f, 0, 0.5f, 0.6f)]];




			}
		}
			break;
		default:
			break;
	}
	[result shuffle];
	return result;
}
@end
