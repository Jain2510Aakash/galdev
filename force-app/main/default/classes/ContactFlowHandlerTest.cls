@isTest
private class ContactFlowHandlerTest {

    // Mock class to avoid actual callouts
    class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testHandleChangeCreate() {
        // Step 1: Create a mock Custom Setting for the callout
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        // Create an Account with mm_INSIGHTS_Id__c
        Account acc = new Account(Name = 'Test Account', mm_INSIGHTS_Id__c = 'INSIGHT-001');
        insert acc;

        // Create Contact linked to Account
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id,
            mm_External_Id__c = 'EXT-001'
        );
        insert con;

        // Prepare input
        ContactFlowHandler.RequestWrapper wrapper = new ContactFlowHandler.RequestWrapper();
        wrapper.contactId = con.Id;
        wrapper.actionType = 'create';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ContactFlowHandler.handleChange(new List<ContactFlowHandler.RequestWrapper>{ wrapper });
        Test.stopTest();
    }

    @isTest
    static void testHandleChangeUpdate() {
        // Create a mock Custom Setting for the callout
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        // Create an Account with mm_INSIGHTS_Id__c
        Account acc = new Account(Name = 'Test Account', mm_INSIGHTS_Id__c = 'INSIGHT-002');
        insert acc;

        // Create Contact linked to Account
        Contact con = new Contact(
            FirstName = 'Update',
            LastName = 'Contact',
            AccountId = acc.Id,
            mm_External_Id__c = 'EXT-002'
        );
        insert con;

        // Prepare input
        ContactFlowHandler.RequestWrapper wrapper = new ContactFlowHandler.RequestWrapper();
        wrapper.contactId = con.Id;
        wrapper.actionType = 'update';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ContactFlowHandler.handleChange(new List<ContactFlowHandler.RequestWrapper>{ wrapper });
        Test.stopTest();
    }
}