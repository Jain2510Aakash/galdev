//Test Class for FetchPolicyTransactionFromInsight
@isTest
public class FetchPolicyTransFromInsightTest {
    class MockInsightCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Sample mock response with one record
            res.setBody('{ "Results": [{ "Id":123,"PolicyId":"1243256","accountId":"001xx000003NG9z","EffectiveDate":"2025-06-01","TransactionNumber": "T-0001","TransactionTypeName": "New Business","Name": "Test Transaction","IsClosed": true,"HasMultiClient": false,"ToDate":"2026-07-10","CommFeeGST":45.0900,"GrossInsurerPremium":3466.9800}]}');
            return res;
        }
    }
    private static void setupTestData() {
        // Insert required Custom Setting
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;

        
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = '123',
            BillingStreet = '123 Main St',
            BillingCity = 'Test City',
            BillingState = 'Tasmania',
            BillingPostalCode = '12345',
            BillingCountry = 'Australia',
            Phone = '555-555-5555'
        );
        insert acc;
        
        // Create Insurance Policy
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Policy',
            NameInsuredId = acc.Id,
            mm_External_Id__c = '1243256'
        );
        insert policy;
        
        InsurancePolicyTransaction iptRec = new InsurancePolicyTransaction();
        iptRec.mm_Insight_Record_ID__c  = '123';    
        iptRec.InsurancePolicyId = policy.Id;
        iptRec.Name = 'Testing IPT';
        insert iptRec;
                    
                    
        // Add transactions
        List<InsurancePolicyTransaction> transList = new List<InsurancePolicyTransaction>();
        for (Integer i = 0; i < 1; i++) {
            transList.add(new InsurancePolicyTransaction(
                Name = 'Transaction ' + i,
                InsurancePolicyId = policy.Id,
                mm_Insight_Record_ID__c = String.valueof(system.now().getTime()).left(4)
            ));
        }
        insert transList;
    }
    @isTest
    static void testGetPolicyTransactionDatafromInsight() {
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;

        
        
        // Create a new Account record
        
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
        
        // Insert InsurancePolicy that matches the external Id
        InsurancePolicy policy = new InsurancePolicy(
            mm_External_Id__c = '1243256',
            NameInsuredId = testAccount.Id,
            Name = 'Test Policy'
        );
        insert policy;
        
        // Register mock callout
        Test.setMock(HttpCalloutMock.class, new MockInsightCallout());
        
        Test.startTest();
        FetchPolicyTransactionFromInsight.getCreatedPolicyTransactionDatafromInsight();
        Test.stopTest();
        
    }
    
    @isTest
    static void testFetchPolicyTransactionScheduler() {
        setupTestData();
        Test.setMock(HttpCalloutMock.class, new MockInsightCallout());
        
        Test.startTest();
        String jobId = System.schedule(
            'Test Policy Transaction Schedule',
            '0 0 0 * * ?',
            new FetchPolicyTransactionScheduler()
        );
        Test.stopTest();
        
        System.assertNotEquals(null, jobId, 'Scheduler job should have been scheduled');
    }
    
    @isTest
    static void testFetchCrtdPolicyTransFromInsightQueu() {
        setupTestData();
        Test.setMock(HttpCalloutMock.class, new MockInsightCallout());
        
        Test.startTest();
        System.enqueueJob(new FetchCrtdPolicyTransFromInsightQueu());
        Test.stopTest();
        
        System.assert(true, 'Queueable job for created policy transactions should execute');
    }
    
    @isTest
    static void testFetchUpdatedPolicyTranFromInsightQue() {
        setupTestData();
            
        Test.setMock(HttpCalloutMock.class, new MockInsightCallout());
        
        Test.startTest();
        System.enqueueJob(new FetchUpdatedPolicyTranFromInsightQue());
        Test.stopTest();
        
        System.assert(true, 'Queueable job for updated policy transactions should execute');
    }
    @isTest(seeAllData = true)
    static void testgetPolicyTeamIdSF() {        
        FetchPolicyTransactionFromInsight.getPolicyTeamIdSF(123);
    }
}