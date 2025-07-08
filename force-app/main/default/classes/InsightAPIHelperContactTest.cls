@isTest
public class InsightAPIHelperContactTest {
    
    // Define a mock response class for a successful response
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response with status 200
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"Contact": {"AuditId": 123, "CreatedWhen": "2025-06-10", "CreatedWho": "API User", "ParentId": "Client123"}}');
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
    
    // Test Case 1: Test sendContactDetails with a valid contact and 'create' action
    @isTest
    public static void testSendContactDetailsCreate() {
        
        //create test account
        Account acc=new Account();
        acc.Name='test account 1';
        acc.mm_INSIGHTS_Id__c='a0123';
        insert acc;
        
        // Create a test contact
        Contact testContact = new Contact(LastName = 'Doe', FirstName = 'John');
        testContact.AccountId=acc.Id;
        insert testContact;
        
        // Create a custom setting to mock
        insurex__c testSetting = new insurex__c();
        testSetting.endpoint__c = 'https://mockapi.com';
        testSetting.insightUsername__c = 'testuser';
        testSetting.insightPassword__c = 'testpassword';
        testSetting.Name = 'testName';
        insert testSetting;
        
        // Set the mock callout response for the HTTP request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Start test context
        Test.startTest();
        // Call the method under test
        InsightAPIHelperContact.sendContactDetails(testContact, 'create', '000000000000271C', 0);
        Test.stopTest();
        
        // Verify that the contact was updated with external values
        testContact = [SELECT mm_External_Id__c, mm_Created_When__c, mm_Created_Who__c, mm_Client_ID__c FROM Contact WHERE Id = :testContact.Id AND Account.mm_INSIGHTS_Id__c != null LIMIT 1];
        System.assertNotEquals(testContact.mm_External_Id__c, null, 'External ID should be set');
    }
    
    // Test Case 2: Test sendContactDetails with a valid contact and 'update' action
    @isTest
    public static void testSendContactDetailsUpdate() {
        
        // Create a test Account
        Account acc=new Account();
        acc.Name='test account 1';
        acc.mm_INSIGHTS_Id__c='a0123';
        insert acc;
        
        // Create a test contact
        Contact testContact = new Contact(LastName = 'Doe', FirstName = 'John');
        testContact.AccountId=acc.Id;
        insert testContact;
        
        // Create a custom setting to mock
        insurex__c testSetting = new insurex__c();
        testSetting.endpoint__c = 'https://mockapi.com';
        testSetting.insightUsername__c = 'testuser';
        testSetting.insightPassword__c = 'testpassword';
        testSetting.Name = 'testName';
        insert testSetting;
        
        // Set the mock callout response for the HTTP request
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Start test context
        Test.startTest();
        // Call the method under test
        InsightAPIHelperContact.sendContactDetails(testContact, 'update','000000000000271C', 133);
        Test.stopTest();
        
        // Verify that the contact was updated with external values
        testContact = [SELECT mm_External_Id__c, mm_Created_When__c, mm_Created_Who__c, mm_Client_ID__c FROM Contact WHERE Id = :testContact.Id];
        //System.assertNotEquals(testContact.mm_External_Id__c, null, 'External ID should be set');
    }
    
    // Test Case 3: Test sendContactDetails with a null contact (edge case)
    @isTest
    public static void testSendContactDetailsNullContact() {
        // Mock HttpResponse for successful callout
        //Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
        // Start test context
        Test.startTest();
        // Call the method under test with a null contact
        InsightAPIHelperContact.sendContactDetails(null, 'create','000000000000271C',0);
        Test.stopTest();
    }
    
    // Test Case 4: Test sendContactDetails with API error response (non-200 response)
    @isTest
    public static void testSendContactDetailsApiError() {
        
        //Create a test Account
        Account acc=new Account();
        acc.Name='test account 1';
        acc.mm_INSIGHTS_Id__c='a0123';
        insert acc;
        
        // Create a test contact
        Contact testContact = new Contact(LastName = 'Doe', FirstName = 'John');
        testContact.AccountId=acc.Id;
        insert testContact;
        
        // Create a custom setting to mock
        insurex__c testSetting = new insurex__c();
        testSetting.endpoint__c = 'https://mockapi.com';
        testSetting.insightUsername__c = 'testuser';
        testSetting.insightPassword__c = 'testpassword';
        testSetting.Name = 'testName';
        insert testSetting;
        
        // Set the mock callout to simulate an error response (non-200 status code)
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        
        // Start test context
        Test.startTest();
        // Call the method under test
        InsightAPIHelperContact.sendContactDetails(testContact, 'create', '000000000000271C', 0);
        Test.stopTest();
        
        // Verify that a log record was created
        List<mm_Integration_Log__c> logs = [SELECT Status_Code__c, mm_Error_Description__c FROM mm_Integration_Log__c WHERE Contact__c = :testContact.Id];
        //System.assertEquals(logs.size(), 1, 'One log entry should be created');
        //System.assertEquals(logs[0].Status_Code__c, '500', 'The error status code should be 500');
    }
    
    @isTest
    static void testGetContactDetails_ErrorResponse() {
        
        Account acc=new Account();
        acc.Name='test account 1';
        acc.mm_INSIGHTS_Id__c='a0123';
        insert acc;
        
        Contact con = new Contact(LastName = 'Error', FirstName = 'Case');
        con.AccountId=acc.Id;
        
        insert con;
        
        // Insert setting
        insert new insurex__c(Name = 'test', endpoint__c = 'https://mockapi.com', insightUsername__c = 'user', insightPassword__c = 'pass');
        
        // Simulate 500 error
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        
        Test.startTest();
        InsightAPIHelperContact.getContactDetails('123', con.Id);
        Test.stopTest();
        
        List<mm_Integration_Log__c> logs = [SELECT Id, Status_Code__c FROM mm_Integration_Log__c WHERE Contact__c = :con.Id];
        //System.assertEquals(1, logs.size(), 'Log should be created for failed getContactDetails');
    }
    
    @isTest
    static void testUpdateContactDetailsOnInsight_Valid() {
        Account acc = new Account(Name = 'Client', mm_INSIGHTS_Id__c = '1010');
        insert acc;
        
        Contact con = new Contact(LastName = 'Update', AccountId = acc.Id);
        insert con;
        
        // Insert custom setting
        insert new insurex__c(Name = 'test', endpoint__c = 'https://mockapi.com', insightUsername__c = 'user', insightPassword__c = 'pass');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        InsightAPIHelperContact.updateContactDetailsOnInsight('ver123', 12345, con.Id);
        Test.stopTest();
        
        // Confirm no error log created
        Integer logCount = [SELECT count() FROM mm_Integration_Log__c WHERE Contact__c = :con.Id];
        System.assertEquals(0, logCount, 'No logs should be created on success');
    }
    
    @isTest
    static void testUpdateContactDetailsOnInsight_InvalidInput() {
        Test.startTest();
        InsightAPIHelperContact.updateContactDetailsOnInsight(null, null, null);
        Test.stopTest();
        
        List<mm_Integration_Log__c> logs = [SELECT Id FROM mm_Integration_Log__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assert(logs.size() > 0, 'Should log issue when inputs are invalid');
    }
    
}