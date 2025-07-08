@isTest
private class FetchPolicyTransPrtcpntSchTest {

    // Mock callout class
    class DummyCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}'); // customize as needed
            res.setStatusCode(200);
            return res;
        }
    }

    private static void setupTestData() {
        // Insert required Custom Setting
        insurex__c setting = new insurex__c(
            Name = 'insurex',
            endpoint__c = 'https://test.com/',
            insightUsername__c = 'testuser',
            insightPassword__c = 'testpass'
        );
        insert setting;

        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            mm_INSIGHTS_Id__c = '1234',
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
            NameInsuredId = acc.Id
        );
        insert policy;

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
    static void testSchedulerExecution() {
        setupTestData();

        Test.setMock(HttpCalloutMock.class, new DummyCalloutMock());

        Test.startTest();
        SchedulableContext sc = null;
        FetchPolicyTransParticipantScheduler scheduler = new FetchPolicyTransParticipantScheduler();
        scheduler.execute(sc);
        Test.stopTest();
    }

    @isTest
    static void testBatchExecution() {
        setupTestData();

        Test.setMock(HttpCalloutMock.class, new DummyCalloutMock());

        Test.startTest();
        BatchFetchPolicyTransactionParticipants batch = new BatchFetchPolicyTransactionParticipants();
        Database.executeBatch(batch, 1);
        Test.stopTest();
    }
}