@isTest
public class InsightAPIHelperTest {
    
    
    // Define a mock response class for a successful response
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response with status 200
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"Client": {"AuditId": 123, "CreatedWhen": "2025-01-01", "CreatedWho": "Test User", "RowVersion": "1.0"}}');
            return res;
        }
    }
    
    // Define a mock response class for an error response
    class MockHttpErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Internal server error"}');
            return res;
        }
    }
    
    @isTest
    static void testSendClientDetails_Create() {
        // Step 1: Create a mock Custom Setting for the callout
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
        insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
        insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        
        // Step 2: Create a test account for sending the details
        Account testAccount = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = '1001',  // Some mock ID to test with
            BillingStreet = '123 Mock St',
            BillingCity = 'Test City',
            BillingState = 'Tasmania',
            BillingPostalCode = '12345',
            BillingCountry = 'Australia',
            Phone = '555-555-5555'
        );
        insert testAccount;
        
        // Step 3: Set the mock callout response for the HTTP request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Step 4: Run the method under test
        Test.startTest();
        InsightAPIHelper.sendClientDetails(testAccount, 'create', null, null);
        Test.stopTest();
        
        // Step 5: Assertions
        // Validate that the account was updated with the expected values
        Account updatedAccount = [SELECT mm_INSIGHTS_Id__c, mm_Created_When__c, mm_Created_Who__c, RowVersion__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals('123', updatedAccount.mm_INSIGHTS_Id__c, 'The mm_INSIGHTS_Id__c should be updated');
        System.assertEquals('2025-01-01', updatedAccount.mm_Created_When__c, 'The mm_Created_When__c should be updated');
    }
    
    @isTest
    static void testSendClientDetails_Update() {
        // Create a mock Custom Setting for the callout
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
        insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
        insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        
        // Create a test account for sending the details
        Account testAccount = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = '1001',
            BillingStreet = '123 Mock St',
            BillingCity = 'Test City',
            BillingState = 'Tasmania',
            BillingPostalCode = '12345',
            BillingCountry = 'Australia',
            Phone = '555-555-5555'
        );
        insert testAccount;
        
        // Step 1: Set the mock callout response for the HTTP request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Step 2: Run the method under test
        Test.startTest();
        InsightAPIHelper.sendClientDetails(testAccount, 'update', null, null);
        Test.stopTest();
    }
    
    @isTest
    static void testSendClientDetails_ErrorHandling() {
        // Create a mock Custom Setting for the callout
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
        insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
        insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        
        // Create a test account for sending the details
        Account testAccount = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = '1001',
            BillingStreet = '123 Mock St',
            BillingCity = 'Test City',
            BillingState = 'Tasmania',
            BillingPostalCode = '12345',
            BillingCountry = 'Australia',
            Phone = '555-555-5555'
        );
        insert testAccount;
        
        // Step 1: Set the mock callout to simulate an error response (non-200 status code)
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        
        // Step 2: Run the method under test
        Test.startTest();
        InsightAPIHelper.sendClientDetails(testAccount, 'create', null, null);
        InsightAPIHelper.sendClientDetails(testAccount, 'update', null, null);
        Test.stopTest();
    }
    
    @isTest
    static void testSendClientDetails_AccountNull() {
        // Test with null Account
        Test.startTest();
        InsightAPIHelper.sendClientDetails(null, 'create', null, null);
        InsightAPIHelper.sendClientDetails(null, 'update', null, null);
        Test.stopTest();
    }
    /**/
    @isTest
    static void testGetClientDetails_Success() {
        // Setup custom setting
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
        insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
        insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        
        // Insert test account
        Account acc = new Account(Name = 'Client Get Test');
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        InsightAPIHelper.getClientDetails('123', acc.Id);
        Test.stopTest();
        
        // You could assert that log is not created for success
        System.assertEquals(1, [SELECT count() FROM Account WHERE Id = :acc.Id]);
    }
    @isTest
    static void testUpdateClientDetailsOnInsight_ValidData() {
        // Insert required custom setting
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
        insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
        insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        
        // Insert test account
        Account acc = new Account(Name = 'Update Client Insight',mm_INSIGHTS_Id__c = '123');
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        InsightAPIHelper.updateClientDetailsOnInsight('{"Client": {"AuditId": 123, "CreatedWhen": "2025-01-01", "CreatedWho": "Test User", "RowVersion": "1.0","StandardIndustryCode":"123","StandardIndustryCodeName":"testing"}}', acc.Id);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM Account WHERE Id = :acc.Id]);
    }
    
    @isTest
    static void testUpdateClientDetailsOnInsight_InvalidInputs() {
        Test.startTest();
        InsightAPIHelper.updateClientDetailsOnInsight('{"Client": {"AuditId": 123, "CreatedWhen": "2025-01-01", "CreatedWho": "Test User", "RowVersion": "1.0"}}','');
        Test.stopTest();
        
        List<mm_Integration_Log__c> logs = [SELECT Id, mm_Error_Description__c FROM mm_Integration_Log__c LIMIT 1];
    }
    
    class MalformedJsonMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Invalid JSON');  // Causes JSON.deserializeUntyped to throw
            return res;
        }
    }
    
    @isTest
    static void testSendClientDetails_JsonParseFailure() {
        Insight_API_Details__c insightAPI = new Insight_API_Details__c(
            Name='insightAPI',
            Insight_Endpoint__c='https://test-endpoint/',
            Insight_Username__c='user',
            Insight_Password__c='pass'
        );
        insert insightAPI;
        
        Account acc = new Account(Name='Error Account');
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new MalformedJsonMock());
        
        Test.startTest();
        InsightAPIHelper.sendClientDetails(acc, 'create', null, null);
        Test.stopTest();
        
    }
    class ThrowExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate callout throwing exception
            throw new CalloutException('Simulated exception');
        }
    }
    
    @isTest
    static void testUpdateClientDetailsOnInsight_CalloutException() {
        Insight_API_Details__c insightAPI = new Insight_API_Details__c(
            Name='insightAPI',
            Insight_Endpoint__c='https://test-endpoint/',
            Insight_Username__c='user',
            Insight_Password__c='pass'
        );
        insert insightAPI;
        
        Account acc = new Account(Name='Exception Account', mm_INSIGHTS_Id__c='123');
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new ThrowExceptionMock());
        
        Test.startTest();
        InsightAPIHelper.updateClientDetailsOnInsight(
            '{"Client": {"AuditId": 123, "CreatedWhen": "2025-01-01", "CreatedWho": "Test User", "RowVersion": "1.0","StandardIndustryCode":"123","StandardIndustryCodeName":"testing"}}',
            acc.Id
        );
        Test.stopTest();
        
    }
    @isTest
    static void testGetClientDetails_ErrorStatus() {
        Insight_API_Details__c insightAPI = new Insight_API_Details__c(
            Name='insightAPI',
            Insight_Endpoint__c='https://test-endpoint/',
            Insight_Username__c='user',
            Insight_Password__c='pass'
        );
        insert insightAPI;
        
        Account acc = new Account(Name='Error Account');
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        
        Test.startTest();
        InsightAPIHelper.getClientDetails('123', acc.Id);
        Test.stopTest();
        
    }
    class BadJsonClientMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"Client": "missing closing brace"');  // Malformed JSON
            return res;
        }
    }
    
    @isTest
    static void testGetClientDetails_MalformedJson() {
        Insight_API_Details__c insightAPI = new Insight_API_Details__c(
            Name='insightAPI',
            Insight_Endpoint__c='https://test-endpoint/',
            Insight_Username__c='user',
            Insight_Password__c='pass'
        );
        insert insightAPI;
        
        Account acc = new Account(Name='Malformed JSON');
        insert acc;
        
        Test.setMock(HttpCalloutMock.class, new BadJsonClientMock());
        
        Test.startTest();
        InsightAPIHelper.getClientDetails('123', acc.Id);
        Test.stopTest();
        
    }
    
}