@isTest
public class FetchPolicyTransCoPartInsightTest {
    class MockHttpResponseFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "something went wrong"}');
            res.setStatusCode(500); // trigger non-200 catch block
            return res;
        }
    }
    
    @isTest
    static void testHttpCalloutExceptionCatchBlock() {
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(12345);
        Test.stopTest();
        
        // Check that error log is created
        List<mm_Integration_Log__c> logs = [SELECT Id FROM mm_Integration_Log__c WHERE mm_Failing_Component__c LIKE '%getPolicyTransactionParticipantDatafromInsight%'];
        System.assert(!logs.isEmpty(), 'Expected error log for outer catch block');
    }
    
    @isTest
    static void testHttpStatusCodeNon200CatchBlock() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseFail());
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(12345);
        Test.stopTest();
        
        List<mm_Integration_Log__c> logs = [SELECT Id, Status_Code__c FROM mm_Integration_Log__c WHERE Status_Code__c = '500'];
        System.assert(!logs.isEmpty(), 'Expected error log for status != 200');
    }
    
    @isTest
    static void testUpsertExceptionCatchBlock() {
        // Setup mock with valid 200 response and dummy client
        Test.setMock(HttpCalloutMock.class, new DummyValid200WithBadData());
        
        // Insert required Account, InsurancePolicyTransaction, etc., if needed
        // that forces upsert error (e.g., missing required fields)
        
        Test.startTest();
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(12345);
        Test.stopTest();
       
    }
    
    // Mock that returns valid JSON but causes upsert to fail (e.g., missing fields)
    class DummyValid200WithBadData implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            String validJson = '{"Clients":[{"ClientId":"111","ClientName":"Test Client","ParentId":"222","Id":"333"}]}';
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(validJson);
            return res;
        }
    }
}