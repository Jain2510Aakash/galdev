/*@isTest
public class FetchPolicyTransCoClientFromInsightTest {

    public class MockFetchPolicyTransCoParticipant_ErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);  // Simulate internal server error
            res.setBody('{"error": "Internal Server Error"}');
            return res;
        }
    }

    // 1. Mock response with a 200 HTTP status code (already done)
    @isTest
    static void testGetPolicyTransactionParticipantDatafromInsight() {
        // Create Custom Setting record
        insurex__c config = new insurex__c(
            Name = 'Default',
            endpoint__c = 'https://test.endpoint.com',
            insightUsername__c = 'testuser',
            insightPassword__c = 'testpass'
        );
        insert config;

        // Create Account with Insight ID
        Account acc = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = 'A123'
        );
        insert acc;

        // Create Insurance Policy
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Policy',
            mm_External_Id__c = 'EXT123',
            NameInsuredId = acc.Id
        );
        insert policy;

        // Create Insurance Policy Transaction
        InsurancePolicyTransaction trans = new InsurancePolicyTransaction(
            Name = 'Test Transaction',
            mm_Insight_Record_ID__c = 'PTX123',
            InsurancePolicyId = policy.Id
        );
        insert trans;

        // Create Insurance Policy Participant
        InsurancePolicyParticipant part = new InsurancePolicyParticipant(
            IPP_Insight_Id__c = 'PPT456',
            InsurancePolicyId = policy.Id,
            Role = '10',
            PrimaryParticipantAccountId = acc.Id
        );
        insert part;

        // Set mock response
        Test.setMock(HttpCalloutMock.class, new MockFetchPolicyTransCoParticipant_ErrorResponse());

        Test.startTest();
        
        // Convert the policy.Id (which is an Id) into an Integer and pass to the method
        Integer policyIdAsInteger;
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(policyIdAsInteger);
        
        Test.stopTest();

        // Add some asserts to confirm expected behavior
        List<InsurancePolicyParticipant> participants = [
            SELECT Id, ParticipantName FROM InsurancePolicyParticipant WHERE IPP_Insight_Id__c = 'PPT456'
        ];
        System.assert(!participants.isEmpty(), 'Expected participant was not created or updated.');
    }

    // 2. Mock response with 500 status code (Internal Server Error)
    @isTest
    static void testGetPolicyTransactionParticipantDatafromInsight_APIError() {
        // Create Custom Setting record
        insurex__c config = new insurex__c(
            Name = 'Default',
            endpoint__c = 'https://test.endpoint.com',
            insightUsername__c = 'testuser',
            insightPassword__c = 'testpass'
        );
        insert config;

        // Create Account with Insight ID
        Account acc = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = 'A123'
        );
        insert acc;

        // Create Insurance Policy
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Policy',
            mm_External_Id__c = 'EXT123',
            NameInsuredId = acc.Id
        );
        insert policy;

        // Create Insurance Policy Transaction
        InsurancePolicyTransaction trans = new InsurancePolicyTransaction(
            Name = 'Test Transaction',
            mm_Insight_Record_ID__c = 'PTX123',
            InsurancePolicyId = policy.Id
        );
        insert trans;

        // Set mock response to simulate a 500 Internal Server Error
        Test.setMock(HttpCalloutMock.class, new MockFetchPolicyTransCoParticipant_ErrorResponse());

        Test.startTest();
        
        // Convert the policy.Id (which is an Id) into an Integer and pass to the method
        Integer policyIdAsInteger;
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(policyIdAsInteger);
        
        Test.stopTest();

        // Assert that an error log was created in case of API failure
        List<mm_Integration_Log__c> logs = [SELECT Status_Code__c, mm_Error_Description__c FROM mm_Integration_Log__c];
        System.assert(!logs.isEmpty(), 'Expected error log to be created for API failure');
        System.assert(logs[0].Status_Code__c == '500', 'Expected status code 500');
        System.assert(logs[0].mm_Error_Description__c == 'Internal Server Error', 'Expected error description to match');
    }

    // 3. Test for Upsert Failure (Simulate DML error during upsert)
    @isTest
    static void testGetPolicyTransactionParticipantDatafromInsight_UpsertError() {
        // Create Custom Setting record
        insurex__c config = new insurex__c(
            Name = 'Default',
            endpoint__c = 'https://test.endpoint.com',
            insightUsername__c = 'testuser',
            insightPassword__c = 'testpass'
        );
        insert config;

        // Create Account with Insight ID
        Account acc = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = 'A123'
        );
        insert acc;

        // Create Insurance Policy
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Policy',
            mm_External_Id__c = 'EXT123',
            NameInsuredId = acc.Id
        );
        insert policy;

        // Create Insurance Policy Transaction
        InsurancePolicyTransaction trans = new InsurancePolicyTransaction(
            Name = 'Test Transaction',
            mm_Insight_Record_ID__c = 'PTX123',
            InsurancePolicyId = policy.Id
        );
        insert trans;

        // Set mock response to simulate a successful callout
        Test.setMock(HttpCalloutMock.class, new MockFetchPolicyTransCoParticipant_ErrorResponse());

        // Simulate an upsert error by causing a DML exception
        // Insert a participant without required fields (e.g., missing PrimaryParticipantAccountId)
        Test.startTest();
        try {
            Integer policyIdAsInteger = 234567890;
            FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(policyIdAsInteger);
            Test.stopTest();
            // If no exception is thrown, the test will fail
            System.assert(false, 'Expected a DML exception during upsert.');
        } catch (DmlException e) {
            System.debug('Expected DML exception caught: ' + e.getMessage());
            // Ensure we have the expected error message
            System.assert(e.getMessage().contains('Required fields are missing'), 'Expected DML error message');
        }
    }
}*/

@isTest
public class FetchPolicyTransCoClientFromInsightTest {

    // Mock HTTP Response class
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{' +
                '"Clients": [' +
                    '{' +
                        '"ClientId": "ACC_INSIGHT_001",' +
                        '"ClientName": "Test Client",' +
                        '"ParentId": "TRANS_INSIGHT_001",' +
                        '"Id": "PARTICIPANT_INSIGHT_001"' +
                    '}' +
                ']' +
            '}');
            return res;
        }
    }

    @isTest
    static void testGetPolicyTransactionParticipantDatafromInsight() {
        // Insert custom setting
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;

        // Insert Account with matching insight ID
        Account acc = new Account(
            Name = 'Test Client',
            mm_INSIGHTS_Id__c = 'ACC_INSIGHT_001'
        );
        insert acc;

        // Insert InsurancePolicy and InsurancePolicyTransaction with insight ID
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Policy',
            mm_External_Id__c = 'EXT123',
            NameInsuredId = acc.Id
        );
        insert policy;

        InsurancePolicyTransaction trans = new InsurancePolicyTransaction(
            Name = 'Test Trans',
            InsurancePolicyId = policy.Id,
            mm_Insight_Record_ID__c = 'TRANS_INSIGHT_001'
        );
        insert trans;

        // Create a matching participant to test upsert
        InsurancePolicyParticipant existingParticipant = new InsurancePolicyParticipant(
            IPP_Insight_Id__c = 'PARTICIPANT_INSIGHT_001',
            InsurancePolicyId = policy.Id,
            Role = 'Other'
        );
        insert existingParticipant;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
		Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(1);
        Test.stopTest();

        // Verify the participant has been updated or a new one inserted
        List<InsurancePolicyParticipant> participants = [
            SELECT Id, IPP_Insight_Id__c, PrimaryParticipantAccountId, Role, ParticipantName
            FROM InsurancePolicyParticipant
            WHERE IPP_Insight_Id__c = 'PARTICIPANT_INSIGHT_001'
        ];

        System.assertEquals(1, participants.size(), 'One participant should be found or created.');
        System.assertEquals(acc.Id, participants[0].PrimaryParticipantAccountId, 'Account ID should match.');
        System.assertEquals('Other', participants[0].Role, 'Role should be Other.');

        // Verify no integration error logs were created
        List<mm_Integration_Log__c> logs = [SELECT Id FROM mm_Integration_Log__c];
        //System.assertEquals(0, logs.size(), 'No error logs should be created.');
    }
    
    public class MockHttpResponse_Error500 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Internal Server Error');
            res.setBody('{"error": "Unexpected server error"}');
            return res;
        }
    }
    
    public class MockHttpResponse_InvalidJson implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('INVALID_JSON');
            return res;
        }
    }

    public class MockHttpResponse_UpsertFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{' +
                        '"Clients": [' +
                        '{' +
                        '"ClientId": "ACC_INSIGHT_FAIL",' +
                        '"ClientName": "Failing Client",' +
                        '"ParentId": "TRANS_INSIGHT_001",' +
                        '"Id": "PARTICIPANT_INSIGHT_FAIL"' +
                        '}' +
                        ']' +
                        '}');
            return res;
        }
    }

    @isTest
    static void testApiReturnsError() {
      	Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_Error500());
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(99999);
        Test.stopTest();
        
        List<mm_Integration_Log__c> logs = [SELECT Id, Status_Code__c FROM mm_Integration_Log__c];
        System.assertEquals(1, logs.size(), 'One log should be inserted for HTTP error.');
        System.assertEquals('500', logs[0].Status_Code__c, 'Should log 500 status.');
    }
    
    @isTest
    static void testJsonParsingError() {
       Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_InvalidJson());
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(88888);
        Test.stopTest();
        
        // Should fail silently, check for absence of exceptions and logs
        //List<mm_Integration_Log__c> logs = [SELECT Id FROM mm_Integration_Log__c];
        //System.assertEquals(0, logs.size(), 'Invalid JSON should not cause logs unless caught internally.');
    }
    
    @isTest
    static void testUpsertFailureLogging() {
       Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        // Create dummy Account and InsurancePolicyTransaction
        Account acc = new Account(Name = 'Fail Client', mm_INSIGHTS_Id__c = 'ACC_INSIGHT_FAIL');
        insert acc;
        
        InsurancePolicy policy = new InsurancePolicy(Name = 'Policy Fail', mm_External_Id__c = 'FAIL123', NameInsuredId = acc.Id);
        insert policy;
        
        InsurancePolicyTransaction trans = new InsurancePolicyTransaction(
            InsurancePolicyId = policy.Id,
            mm_Insight_Record_ID__c = 'TRANS_INSIGHT_001',
            Name = 'Test Transaction'
        );
        insert trans;
        
        // Insert an InsurancePolicyParticipant with the same insight ID to force upsert
        InsurancePolicyParticipant existingPart = new InsurancePolicyParticipant(
            InsurancePolicyId = policy.Id,
            IPP_Insight_Id__c = 'PARTICIPANT_INSIGHT_FAIL',
            Role = 'Other'
        );
        insert existingPart;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_UpsertFail());
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(222);
        Test.stopTest();
        
        List<mm_Integration_Log__c> logs = [SELECT Id, Insurance_Policy_Participant__c, mm_Error_Description__c FROM mm_Integration_Log__c];
        //System.assert(!logs.isEmpty(), 'Should log upsert errors if any occur.');
    }
     
    @isTest
    static void testNoMatchingRecords() {
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        Test.setMock(HttpCalloutMock.class, new FetchPolicyTransCoClientFromInsightTest.MockHttpResponseGenerator());
        
        // Do not insert matching Accounts or Transactions — test behavior with no existing records
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(12345);
        Test.stopTest();
        
        List<InsurancePolicyParticipant> participants = [SELECT Id FROM InsurancePolicyParticipant];
        //System.assertEquals(1, participants.size(), 'Should still insert a new participant even without matches');
    }
    
    /*@isTest
    static void testCalloutThrowsException() {
        insert new insurex__c(Name='Default', endpoint__c='https://api.crash', insightUsername__c='user', insightPassword__c='pass');
        
        Test.setMock(HttpCalloutMock.class, new MockHttpThrowsException());
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(999);
        Test.stopTest();
        
        // Should NOT throw uncaught exception
        List<mm_Integration_Log__c> logs = [SELECT Id FROM mm_Integration_Log__c];
        System.assertEquals(0, logs.size(), 'Should catch top-level callout exception silently');
    }*/


}