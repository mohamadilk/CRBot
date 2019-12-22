//
//  GoogleSheetsHandler.m
//  Crypto Bot
//
//  Created by mohamad ilk on 22.12.2019.
//  Copyright © 2019 Mohammad Ilkhani. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleAPIClientForREST/GTLRSheets.h>

@implementation GoogleSheetsHandler : NSObject

- (void) fetchSheetsData {
    
    NSString *clientId = @"511335688174-o9lmjig231hkhcebllc3l0ba2afal7u9.apps.googleusercontent.com";
    GTLRSheetsService *service = [[GTLRSheetsService alloc] init];
    service.APIKey = @"AIzaSyAl9h29vS2WJxXcEHMP83idj6dUZ3SkYVs";
    
    NSString *spreadsheetId = @"1eoc9LJYe6odgRbbCs7DCor4ZcqwM5qxhmZz11PZyiKI"; // Sheet ID
    NSString *range = @"Input"; // Page name

    GTLRSheets_ValueRange *valueRange = [[GTLRSheets_ValueRange alloc] init];
    NSArray *values = [[NSArray alloc] initWithObjects:@"Symbol", @"Candle_Limits",@"Price_type",@"Time_Frame",@"Update_Data", nil];
    NSArray *valuesContainer = [[NSArray alloc] initWithObjects:values, nil];
    [valueRange setValues:valuesContainer];
    // The A1 notation of the values to retrieve.

    // How dates, times, and durations should be represented in the output.
    // This is ignored if value_render_option is
    // FORMATTED_VALUE.
    // The default dateTime render option is [DateTimeRenderOption.SERIAL_NUMBER].
    NSString *dateTimeRenderOption = @""; // TODO: Update placeholder value.
    
//    GTLRSheetsQuery *query = [[GTLRSheetsQuery alloc] initWithPathURITemplate:<#(nonnull NSString *)#> HTTPMethod:<#(nullable NSString *)#> pathParameterNames:<#(nullable NSArray<NSString *> *)#>]
//    [service executeQuery:<#(nonnull id<GTLRQueryProtocol>)#> completionHandler:<#^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError)handler#>]
}

@end
