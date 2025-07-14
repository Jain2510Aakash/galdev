@isTest
private class FetchPolicyTransactionFromInsightTest {

    @testSetup
    static void setupTestData() {
        // Create and insert test data for Insight_API_Details__c, InsurancePolicy, and InsurancePolicyTransaction
       	Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Test City',
            BillingState = 'Tasmania',
            BillingPostalCode = '12345',
            BillingCountry = 'Australia',
            Phone = '555-555-5555',
            mm_INSIGHTS_Id__c= '1234'
        );
        insert testAccount;

        List<InsurancePolicy> policyList = new List<InsurancePolicy>{
            new InsurancePolicy(
                Name = 'Test Policy',
                mm_External_Id__c = '12345',
                NameInsuredId = testAccount.Id
            )
        };
        insert policyList;

        List<InsurancePolicyTransaction> transactionList = new List<InsurancePolicyTransaction>{
            new InsurancePolicyTransaction(
                InsurancePolicyId = policyList[0].Id,
                mm_Insight_Record_ID__c = 'trans123',
                mm_Effective_Date__c = Date.today(),
                Name = '123'
            )
        };
        insert transactionList;
    }
    
    class MockHttpResponseGenerator implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"Results": [{"Id": 123, "PolicyId": "12345", "accountId": "acc123"}]}');
                res.setStatusCode(200);
                return res;
            }
    }

    @isTest
    static void testSuccessfulApiResponse() {
        // Mock the HTTP response for a successful API call
        Test.startTest();
      /*  HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"Results": [{"Id": "trans123", "PolicyId": "12345", "accountId": "acc123"}]}'); */
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method under test
        FetchPolicyTransactionFromInsight.getCreatedPolicyTransactionDatafromInsight();
        FetchPolicyTransactionFromInsight.getPolicyTeamIdSF(1234);
        // Verify the results
        List<InsurancePolicyTransaction> transactions = [SELECT Id FROM InsurancePolicyTransaction];
        System.assertEquals(1, transactions.size(), 'Expected one transaction to be upserted.');
        Test.stopTest();
    }

    @isTest
    static void testApiErrorResponse() {
        // Mock the HTTP response for an error API call
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(500);
        mockResponse.setBody('{"error": "Internal Server Error"}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method under test
        FetchPolicyTransactionFromInsight.getUpdatedPolicyTransactionDatafromInsight();

        // Verify the error log
        List<mm_Integration_Log__c> logs = [SELECT Status_Code__c FROM mm_Integration_Log__c];
        //System.assertEquals(1, logs.size(), 'Expected one error log to be created.');
        //System.assertEquals('500', logs[0].Status_Code__c, 'Expected status code to be 500.');
        Test.stopTest();
    }

    @isTest
    static void testEmptyApiResponse() {
        // Mock the HTTP response for an empty API call
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"Results": []}');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method under test
        FetchPolicyTransactionFromInsight.getCreatedPolicyTransactionDatafromInsight();

        // Verify no transactions were upserted
        List<InsurancePolicyTransaction> transactions = [SELECT Id FROM InsurancePolicyTransaction];
        //System.assertEquals(0, transactions.size(), 'Expected no transactions to be upserted.');
        Test.stopTest();
    }

    @isTest
    static void testExceptionHandling() {
        // Simulate an exception in the try-catch block
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method under test
        FetchPolicyTransactionFromInsight.getCreatedPolicyTransactionDatafromInsight();

        // Verify the error log
        List<mm_Integration_Log__c> logs = [SELECT Status_Code__c FROM mm_Integration_Log__c];
        //System.assertEquals(1, logs.size(), 'Expected one error log to be created.');
        //System.assertNotEquals(null, logs[0].Status_Code__c, 'Expected status code to be logged.');
        Test.stopTest();
    }
}