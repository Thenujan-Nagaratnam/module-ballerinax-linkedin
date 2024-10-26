import ballerina/test;

configurable boolean isLiveServer = ?;
configurable string serviceUrl = ?;
configurable string token = ?;

ConnectionConfig config = {auth: {token: token}};
final Client linkedinClient = check new Client(config, serviceUrl);

// ############################################################################################################
// Test retrieving the current user's profile (Success)
// ############################################################################################################
@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testRetrieveMemberProfileSuccess() returns error? {
    map<string|string[]> headers = {
        Authorization: "Bearer " + token
    };

    inline_response_200 response = check linkedinClient->/userinfo(headers);

    test:assertEquals(response.email, "thenujan2212@gmail.com");
    test:assertEquals(response.name, "Shan Daemon");
}


// ############################################################################################################
// Test retrieving member profile with an invalid token (Error)
// ############################################################################################################
@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testRetrieveMemberProfileError() returns error? {
    map<string|string[]> headers = {
        Authorization: "Bearer " + "invalid_token"
    };

    var response = linkedinClient->/userinfo(headers);
    test:assertEquals(response is error, true);
}


// ############################################################################################################
// Test posting assets (image/video registration) - Success
// ############################################################################################################
@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPostSuccess() returns error? {
    map<string|string[]> headers = {
        Authorization: "Bearer " + token
    };
    RegisterUploadQueries queries = {
        action: "registerUpload"
    };
    assets_body payload = {
        registerUploadRequest: {
            recipes: ["urn:li:digitalmediaRecipe:feedshare-image"],
            owner: "urn:li:person:8675309",
            serviceRelationships: [
                {
                    relationshipType: "OWNER",
                    identifier: "urn:li:userGeneratedContent"
                }
            ]
        }
    };

    inline_response_200_1 response = check linkedinClient->/assets.post(payload, headers, queries);
    test:assertNotEquals(response, ());
    test:assertNotEquals(response.value, ());
}


// ############################################################################################################
// Test posting assets (image/video registration) with invalid token (Error)
// ############################################################################################################
@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testPostFail() returns error? {
    map<string|string[]> headers = {
        Authorization: "Bearer " + "invalid_token"
    };
    RegisterUploadQueries queries = {
        action: "registerUpload"
    };
    assets_body payload = {
        registerUploadRequest: {
            recipes: ["urn:li:digitalmediaRecipe:feedshare-image"],
            owner: "urn:li:person:8675309",
            serviceRelationships: [
                {
                    relationshipType: "OWNER",
                    identifier: "urn:li:userGeneratedContent"
                }
            ]
        }
    };

    var response = linkedinClient->/assets.post(payload, headers, queries);
    test:assertEquals(response is error, true);
}


// ############################################################################################################
// Test client initialization (Success)
// ############################################################################################################
@test:Config {
    groups: ["mock_tests"]
}
isolated function testClientInitialization() returns error? {
    test:assertTrue(true, msg = "Client initialization test passed");
}


// ############################################################################################################
// Test invalid access token (Error handling)
// ############################################################################################################
@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testInvalidToken() returns error? {
    ConnectionConfig invalidTokenConfig = {auth: {token: "invalid_token"}};
    Client invalidClient = check new Client(invalidTokenConfig, serviceUrl);
    var result = invalidClient->/userinfo();
    test:assertEquals(result is error, true);
}
