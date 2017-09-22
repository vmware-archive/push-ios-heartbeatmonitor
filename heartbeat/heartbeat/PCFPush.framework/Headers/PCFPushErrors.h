/*  Copyright (C) 2015-Present Pivotal Software, Inc. All rights reserved
 *
 *  This program and the accompanying materials are made available under
 *  the terms of the under the Apache License, Version 2.0 (the "License”);
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#ifndef PCFPushSDK_PCFPushErrors_h
#define PCFPushSDK_PCFPushErrors_h

/**
 * Defines the domain for errors that are specific to the CF Push SDK Client
 */
OBJC_EXPORT NSString *const PCFPushErrorDomain;

/**
 * Defines the error codes that are specific to the CF Push SDK Client
 */

typedef NS_ENUM(NSInteger, PCFPushErrorCodes) {

    /**
     * The connection returned both nil error and response data. This shouldn't happen.
     */
    PCFPushBackEndConnectionEmptyErrorAndResponse = 18,

    /**
     * The back-end server returned a response that was not an HTTP response object
     */
    PCFPushBackEndRegistrationNotHTTPResponseError = 19,

    /**
     * Failed to authenticate while communicating with the back-end server. Can happen if the platform_uuid/platform_secret parameters are wrong.
     */
    PCFPushBackEndAuthenticationError = 20,

    /**
     * The back-end server returned a failure (i.e.: < 200 or >= 300) HTTP status code while attempting to register.
     */
    PCFPushBackEndConnectionFailedHTTPStatusCode = 22,
    
    /**
     * The back-end server returned an empty response while attempting to register.
     */
    PCFPushBackEndRegistrationEmptyResponseData = 23,

    /**
     * Failed to build a valid unregistration request.
     */
    PCFPushBackEndInvalidRequestStatusCode = 32,

    /**
     * The registration request JSON data object was badly formatted.
     */
    PCFPushBackEndDataUnparseable = 40,
    
    /**
     * The back-end server did not return a device_uuid after attempting to register.
     */
    PCFPushBackEndRegistrationResponseDataNoDeviceUuid = 42,

    /**
     * Tried to subscribe to tags when not already registered.
     */
    PCFPushNotRegistered = 50,
};

#endif
