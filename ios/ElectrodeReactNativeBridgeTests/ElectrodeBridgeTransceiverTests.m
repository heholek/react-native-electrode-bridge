//
//  ElectrodeBridgeTransceiverTests.m
//  ElectrodeReactNativeBridge
//
//  Created by Claire Weijie Li on 3/27/17.
//  Copyright © 2017 Walmart. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ElectrodeBridgeBaseTests.h"
#import "TestRequestHandler.h"
#import "ElectrodeBridgeResponse.h"
#import "Person.h"

@interface ElectrodeBridgeTransceiverTests : ElectrodeBridgeBaseTests

@end

@implementation ElectrodeBridgeTransceiverTests

-(void)testSendTimeOutRequest
{
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendTimeOutRequest"];
    
    [self addMockEventListener:[[MockJSEeventListener alloc] initWithRequestBlock:^(ElectrodeBridgeRequestNew *request) {
        XCTAssertNotNil(request);
    }] forName:@"test1"];
    
    id<ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    ElectrodeBridgeRequestNew *request = [ElectrodeBridgeRequestNew createRequestWithName:@"test1"];
    MockElectrodeBridgeResponseListener *listener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation failureBlock:^(id failureMessage) {
        XCTAssertNotNil(failureMessage);
        [expectation fulfill];
    }];
    
    [nativeBridge sendRequest:request withResponseListener:listener];
    
    
    [self waitForExpectationToFullFillOrTimeOut];

}

-(void)testSendRequestWithEmptyRequestDataAndNEmptyResponseNativeToNative
{
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSampleRequestNativeToNative"];
    id<ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    
    ElectrodeBridgeRequestNew *request = [ElectrodeBridgeRequestNew createRequestWithName:@"testRequest" data:nil];

    [nativeBridge regiesterRequestHandlerWithName:@"testRequest" handler:[[TestRequestHandler alloc] initWithOnRequestBlock:^(NSDictionary *data, id<ElectrodeBridgeResponseListener> responseListener) {
        XCTAssertNil(data);
        [responseListener onSuccess:nil];
    }] error:nil];


    MockElectrodeBridgeResponseListener *listener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation successBlock:^(NSDictionary *data) {
        XCTAssertNil(data);
        [expectation fulfill];
    }];
    [nativeBridge sendRequest:request withResponseListener:listener];

    [self waitForExpectationToFullFillOrTimeOut];
}

-(void)testSendRequestWithEmptyRequestDataAndNEmptyResponseJSToNative
{
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSampleRequestNativeToNative"];

    id<ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    id<ElectrodeReactBridge> reactBridge = [self getReactBridge];

    [nativeBridge regiesterRequestHandlerWithName:@"testRequest" handler:[[TestRequestHandler alloc] initWithOnRequestBlock:^(NSDictionary *data, id<ElectrodeBridgeResponseListener> responseListener) {
        XCTAssertNil(data);
        [responseListener onSuccess:nil];
    }] error:nil];

    [self addMockEventListener:[[MockJSEeventListener alloc] initWithResponseBlock:^(ElectrodeBridgeResponse *response) {
        XCTAssertNotNil(response);
        [expectation fulfill];
    }] forName:@"testRequest"];

    NSDictionary *jsRequest = [self createBridgeRequestForName:@"testRequest" id:[ElectrodeBridgeMessage UUID] data:nil];
    [reactBridge sendMessage:jsRequest];

    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendRequestToGetArrayFromRCTToNative {
   
    NSString* const testRequest = @"testRequest";
    
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
    
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendRequestToGetArrayFromJsToNative"];
    
    NSArray* testArray = @[@"apple", @"mango", @"orange"];
    
    [nativeBridge regiesterRequestHandlerWithName:testRequest handler:[[TestRequestHandler alloc] initWithOnRequestBlock:^(NSDictionary *data, id<ElectrodeBridgeResponseListener> responseListener) {
        [responseListener onSuccess:data];
    }] error:nil];
    
    [self addMockEventListener:[[MockJSEeventListener alloc] initWithResponseBlock:^(ElectrodeBridgeResponse *response) {
        XCTAssertNotNil(response);
        XCTAssertEqual(testArray, response.data, @"Sent and received data is different");
        [expectation fulfill];
    }] forName:testRequest];
    
    NSDictionary *jsRequest = [self createBridgeRequestForName:testRequest id:[ElectrodeBridgeMessage UUID] data:testArray];
    [reactBridge sendMessage:jsRequest];
    
    [self waitForExpectationToFullFillOrTimeOut];
}


- (void)testSendRequestGetEmptyArrayFromRCTToNative {
    
    NSString* const testRequest = @"testRequest";
    
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
    
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendRequestToGetArrayFromJsToNative"];
    
    NSArray* emptyArray = @[];
    
    [nativeBridge regiesterRequestHandlerWithName:testRequest handler:[[TestRequestHandler alloc] initWithOnRequestBlock:^(NSDictionary *data, id<ElectrodeBridgeResponseListener> responseListener) {
        [responseListener onSuccess:data];
    }] error:nil];
    
    [self addMockEventListener:[[MockJSEeventListener alloc] initWithResponseBlock:^(ElectrodeBridgeResponse *response) {
        XCTAssertNotNil(response);
        XCTAssertEqual(emptyArray, response.data, @"Sent and received data is different");
        [expectation fulfill];
    }] forName:testRequest];
    
    NSDictionary *jsRequest = [self createBridgeRequestForName:testRequest id:[ElectrodeBridgeMessage UUID] data:emptyArray];
    [reactBridge sendMessage:jsRequest];
    
    [self waitForExpectationToFullFillOrTimeOut];

}

//tests Native request to JS with empty "data" (data = nil) as a response
- (void)testSendRequestWithRequestDataAndEmptyResponseWithJSRequestHandler {
    
    NSString* const name = @"testingSendRequest";
    ElectrodeBridgeRequestNew* request = [ElectrodeBridgeRequestNew createRequestWithName:name data:nil];
    
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"sendRequestWithRequestDataAndEmptyResponseWithJSRequestHandler"];
    
    [self addMockEventListener:[[MockJSEeventListener alloc]  initWithRequestBlock:^(ElectrodeBridgeRequestNew *request) {
        id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
        //do mock JS response here
        NSDictionary* emptyResponse = [self createResponseDataWithName:name id:request.messageId data:nil];
        [reactBridge sendMessage:emptyResponse];
    }] forName:name];
    
    MockElectrodeBridgeResponseListener* responseListener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation successBlock:^(NSDictionary *data) {
        XCTAssertNil(data);
        [expectation fulfill];
    }];
    
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    [nativeBridge sendRequest:request withResponseListener:responseListener];
    
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendRequestWithRequestDataAndExpectStringResponseFromNativeToJS {
    
    NSString* const name = @"sendRequest";
    NSString* const sendResponseString = @"responseString";
    ElectrodeBridgeRequestNew* request = [ElectrodeBridgeRequestNew createRequestWithName:name data:@"requestString"];

    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendRequestWithRequestDataAndExpectStringResponseFromNativeToJS"];
    
    [self addMockEventListener:[[MockJSEeventListener alloc]  initWithRequestBlock:^(ElectrodeBridgeRequestNew *request) {
        id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
        //do mock JS response here
        NSDictionary* response = [self createResponseDataWithName:name id:request.messageId data:sendResponseString];
        [reactBridge sendMessage:response];
    }] forName:name];

    MockElectrodeBridgeResponseListener* responseListener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation successBlock:^(id data) {
        XCTAssertNotNil(data, @"Response is nil. There's an error in receiving response");
        XCTAssertEqual(sendResponseString, data, @"Sent and received response data doesn't match");
        [expectation fulfill];
    }];
    
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    [nativeBridge sendRequest:request withResponseListener:responseListener];
    
    [self waitForExpectationToFullFillOrTimeOut];
}


- (void)testSendRequestWithRequestDataAndExpectDictionaryResponseFromNativeToJS {
   
    NSString* const name = @"sendRequest";
    NSDictionary* const sendResponseDictionary = @{@"response" : @"responseDictionary"};
    
    ElectrodeBridgeRequestNew* request = [ElectrodeBridgeRequestNew createRequestWithName:name data:@"requestDictionary"];
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendRequestWithRequestDataAndExpectDictionaryResponseFromNativeToJS"];
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    
    [self addMockEventListener:[[MockJSEeventListener alloc]  initWithRequestBlock:^(ElectrodeBridgeRequestNew *request) {
        id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
        //do mock JS response here
        NSDictionary* response = [self createResponseDataWithName:name id:request.messageId data:sendResponseDictionary];
        [reactBridge sendMessage:response];
    }] forName:name];
    
    MockElectrodeBridgeResponseListener* responseListener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation successBlock:^(id data) {
        XCTAssertNotNil(data, @"Response is nil. There's an error in receiving response");
        XCTAssertEqual(sendResponseDictionary, data, @"Sent and received response data doesn't match");
        [expectation fulfill];
    }];
    
    [nativeBridge sendRequest:request withResponseListener:responseListener];
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendRequestWithPrimitiveTypeResponseFromNativeToJS {
   
    NSString* const name = @"sendRequest";
    int integer = 2;
    NSNumber* number = [NSNumber numberWithInt:integer];
   
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
    
    ElectrodeBridgeRequestNew* request = [ElectrodeBridgeRequestNew createRequestWithName:name data:@"requestPrimitiveType"];
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendRequestWithPrimitiveTypeResponseFromNativeToJS"];
    
    [self addMockEventListener:[[MockJSEeventListener alloc]  initWithRequestBlock:^(ElectrodeBridgeRequestNew *request) {
        XCTAssertEqual(name, request.name, @"Names mismatch, error");
        //do mock JS response here
        NSDictionary* primitiveDataTypeResponse = [self createResponseDataWithName:name id:request.messageId data:number];
        [reactBridge sendMessage:primitiveDataTypeResponse];
    }] forName:name];
    
    MockElectrodeBridgeResponseListener* responseListener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation successBlock:^(id data) {
        XCTAssertNotNil(data, @"Response is nil. There's an error in receiving response");
        XCTAssertEqual(number, data, @"Sent and received response data doesn't match");
        [expectation fulfill];
    }];
    
    [nativeBridge sendRequest:request withResponseListener:responseListener];
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendRequestWithBooleanFromNativeToJS {
    NSString* const name = @"sendRequest";
    BOOL isYes = YES;
    NSNumber* boolean = [NSNumber numberWithBool:isYes];

    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    id <ElectrodeReactBridge> reactBridge = [self getReactBridge];

    ElectrodeBridgeRequestNew* request = [ElectrodeBridgeRequestNew createRequestWithName:name data:@"requestBooleanType"];
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendRequestWithBooleanFromNativeToJS"];

    [self addMockEventListener:[[MockJSEeventListener alloc]  initWithRequestBlock:^(ElectrodeBridgeRequestNew *request) {
        XCTAssertEqual(name, request.name, @"Names mismatch, error");
        //do mock JS response here
        NSDictionary* booleanTypeResponse = [self createResponseDataWithName:name id:request.messageId data:boolean];
        [reactBridge sendMessage:booleanTypeResponse];
    }] forName:name];

    MockElectrodeBridgeResponseListener* responseListener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation successBlock:^(id data) {
        XCTAssertNotNil(data, @"Response is nil. There's an error in receiving response");
        XCTAssertEqual([data boolValue], isYes, @"Sent and received response data doesn't match");
        [expectation fulfill];
    }];

    [nativeBridge sendRequest:request withResponseListener:responseListener];
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendRequestWithComplexDataFromNativeToJS {
   
    NSString* const name = @"sendRequest";
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    id <ElectrodeReactBridge> reactBridge = [self getReactBridge];

    NSDictionary* attributes = @{
                                 @"firstname" : @"Mo",
                                 @"lastname"  : @"Abhi",
                                 @"gender"    : @"male",
                                 @"age"       : @"28",
                                 @"company"   : @"xyz"
                                 };
    Person* person = [[Person alloc]  initWithAttributes:attributes];
    XCTAssertNotNil(person, @"Error in creating person object");
    
    ElectrodeBridgeRequestNew* request = [ElectrodeBridgeRequestNew createRequestWithName:name data:person];
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"testSendRequestWithComplexDataFromNativeToJS"];
  
    [self addMockEventListener:[[MockJSEeventListener alloc]  initWithRequestBlock:^(ElectrodeBridgeRequestNew *request) {
        XCTAssertEqual(name, request.name, @"Names mismatch, error");
        //do mock JS response here
        NSDictionary* complexData = [self createResponseDataWithName:name id:request.messageId data:person];
        [reactBridge sendMessage:complexData];
    }] forName:name];
    
    MockElectrodeBridgeResponseListener* responseListener = [[MockElectrodeBridgeResponseListener alloc] initWithExpectation:expectation successBlock:^(id data) {
        Person* response = (Person*) data;
        XCTAssertNotNil(response, @"Response is nil. There's an error in receiving response");
        XCTAssertEqual([[person attributes] objectForKey:@"firstname"], [[response attributes] objectForKey:@"firstname"] , @"Sent and received response data doesn't match");
        XCTAssertEqual([[person attributes] objectForKey:@"lastname"], [[response attributes] objectForKey:@"lastname"] , @"Sent and received response data doesn't match");
        XCTAssertEqual([[person attributes] objectForKey:@"gender"], [[response attributes] objectForKey:@"gender"] , @"Sent and received response data doesn't match");
        XCTAssertEqual([[person attributes] objectForKey:@"age"], [[response attributes] objectForKey:@"age"] , @"Sent and received response data doesn't match");
        [expectation fulfill];
    }];
    
    [nativeBridge sendRequest:request withResponseListener:responseListener];
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendEventFromNativeToRCT {
  
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    NSString* testEventName = @"com.walmart.ern.testevent";
    NSString* testData = @"testeventdata";
    
    ElectrodeBridgeEventNew* event = [ElectrodeBridgeEventNew createEventWithName:testEventName data:testData];
    XCTAssertNotNil(event, @"Event instance is nil");
    
    [self addMockEventListener:[[MockJSEeventListener alloc] initWithEventBlock:^(ElectrodeBridgeEventNew *event) {
        XCTAssertEqual(testEventName, event.name, @"Not an event RCT expected!");
        XCTAssertEqual(testData, event.data, @"Not an event RCT expected!");
    }] forName:testEventName];
    
    [nativeBridge sendEvent:event];
}

- (void)testSendEventFromNativeToNative {
    
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    NSString* testEventName = @"com.walmart.ern.nativetonativeevent";
    NSString* data = @"nativeeventdata";
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"waitfornativeeventtocomplete"];
    
    ElectrodeBridgeEventNew* event = [ElectrodeBridgeEventNew createEventWithName:testEventName data:data];
    
    MockElectrodeBridgeEventListener* eventListener = [[MockElectrodeBridgeEventListener alloc] initWithonEventBlock:^(id  _Nullable payLoad) {
        XCTAssertEqual(payLoad, data, @"Failure, received a different event!!");
        [expectation fulfill];
    }];
    XCTAssertNotNil(eventListener, @"EventListener instance is nil");
    
    [nativeBridge addEventListenerWithName:testEventName eventListener:eventListener];
    //then dispatch an event to the native
    [nativeBridge sendEvent:event];
    
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendEventWithSimpleDataFromRCTToNative {
  
    id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
   
    NSString* testEventName = @"com.walmart.ern.reacttonativeevent";
    NSString* data = @"reacteventdata";
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"waitforreacteventtocomplete"];
   
    ElectrodeBridgeEventNew* event = [ElectrodeBridgeEventNew createEventWithName:testEventName data:data];
    XCTAssertNotNil(event, @"event instance is nil");
    
    MockElectrodeBridgeEventListener* eventListener = [[MockElectrodeBridgeEventListener alloc] initWithonEventBlock:^(id  _Nullable payLoad) {
        XCTAssertEqual(payLoad, data, @"Failure, received a different event!!");
        [expectation fulfill];
    }];
    
    [nativeBridge addEventListenerWithName:testEventName eventListener:eventListener];
    NSDictionary* eventMessage = [self createEventDataWithName:testEventName id:[ElectrodeBridgeMessage UUID] data:data];
    [reactBridge sendMessage:eventMessage];
    
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendEventWithComplexDataFromRCTToNative {
  
    id <ElectrodeReactBridge> reactBridge = [self getReactBridge];
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    
    NSString* testEventName = @"com.walmart.ern.reacttonativeevent";
    
    NSDictionary* data = @{
                           @"string" : @"stringValue",
                           @"integer" : [NSNumber numberWithFloat:18.333333],
                           @"array" : [NSArray arrayWithObjects:@"1", @"2",@"3", nil],
                           @"dictionary" : @{
                                   @"key" : @"value"
                                   }
                           };
    
    XCTestExpectation* expectation = [self createExpectationWithDescription:@"waitforreacteventtocomplete"];
    
    ElectrodeBridgeEventNew* event = [ElectrodeBridgeEventNew createEventWithName:testEventName data:data];
    XCTAssertNotNil(event, @"event instance is nil");
    
    MockElectrodeBridgeEventListener* eventListener = [[MockElectrodeBridgeEventListener alloc] initWithonEventBlock:^(id  _Nullable payLoad) {
        XCTAssertEqual(payLoad, data, @"Failure, received a different event!!");
        [expectation fulfill];
    }];
    
    [nativeBridge addEventListenerWithName:testEventName eventListener:eventListener];
    
    NSDictionary* eventMessage = [self createEventDataWithName:testEventName id:[ElectrodeBridgeMessage UUID] data:data];
    [reactBridge sendMessage:eventMessage];
    
    [self waitForExpectationToFullFillOrTimeOut];
}

- (void)testSendEventWithComplexDataFromNativeToRCT {
   
    id <ElectrodeNativeBridge> nativeBridge = [self getNativeBridge];
    NSString* testEventName = @"com.walmart.ern.testevent";
    
    NSDictionary* data = @{
                           @"string" : @"stringValue",
                           @"integer" : [NSNumber numberWithFloat:18.333333],
                           @"array" : [NSArray arrayWithObjects:@"1", @"2",@"3", nil],
                           @"dictionary" : @{
                                   @"key" : @"value"
                                   }
                           };
    ElectrodeBridgeEventNew* event = [ElectrodeBridgeEventNew createEventWithName:testEventName data:data];
    XCTAssertNotNil(event, @"Event instance is nil");
    
    [self addMockEventListener:[[MockJSEeventListener alloc] initWithEventBlock:^(ElectrodeBridgeEventNew *event) {
        XCTAssertEqual(testEventName, event.name, @"Not an event RCT expected!");
        XCTAssertEqual(data, event.data, @"Not an event RCT expected!");
    }] forName:testEventName];
    
    [nativeBridge sendEvent:event];
}

- (XCTestExpectation*)createExpectationWithDescription:(nullable NSString*)description {
    return [self expectationWithDescription:description];
}

- (void)waitForExpectationToFullFillOrTimeOut {
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError * _Nullable error) {
        NSLog(@"Test timedout");
    }];
}
@end
