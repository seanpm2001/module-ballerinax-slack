// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerinax/slack;
import ballerina/os;

slack:ConnectionConfig slackConfig = {
    auth: {
        token: os:getEnv("SLACK_TOKEN")
    }
};

public function main() returns error? {
    slack:Client slackClient = check new(slackConfig);

    // Get members of a channel.
    stream<string,error?> resultStream = check slackClient->getConversationMembers("channelName", 
            "<startOfTimeRange in epoch>", "<endOfTimeRange in epoch>");
    if (resultStream is stream<string,error?>) {        
        error? e = resultStream.forEach(isolated function (string memberId) {
            log:printInfo(memberId);
        });
    }
}
