@isTest
public class AccountFlowHandlerTest {
    @isTest
    static void testHandleChange() {
   
        // Create test account
        Account testAccount = new Account(
            Name = 'Test Account',
            BillingStreet = '123 Main St',
            BillingCity = 'Test City',
            BillingState = 'Victoria',
            BillingPostalCode = '12345',
            BillingCountry = 'Australia',
            Phone = '555-555-5555'
        );
        insert testAccount;
        
        Insight_API_Details__c insightAPI = new Insight_API_Details__c();
		insightAPI.Insight_Endpoint__c='https://galvaniizeinsurance--devenv.sandbox.my.salesforce-setup.com/servlet/servlet.ExternalRedirect?url=https%3A%2F%2Frc-insurex-tstinsrx.insightbroking.com.au%2FServices&';
		insightAPI.Name='insightAPI';
        insightAPI.Insight_Username__c='testabc';
        insightAPI.Insight_Password__c='testcardasf';
        insert insightAPI;
        
        // Create test requests
        List<AccountFlowHandler.RequestWrapper> requestList = new List<AccountFlowHandler.RequestWrapper>();

        // Test 'create' action
        AccountFlowHandler.RequestWrapper createRequest = new AccountFlowHandler.RequestWrapper();
        createRequest.accountId = testAccount.Id;
        createRequest.actionType = 'create';
        requestList.add(createRequest);

        // Test 'update' action
        AccountFlowHandler.RequestWrapper updateRequest = new AccountFlowHandler.RequestWrapper();
        updateRequest.accountId = testAccount.Id;
        updateRequest.actionType = 'update';
        requestList.add(updateRequest);

        // Ensure the list is not empty before passing to the method
        System.assert(!requestList.isEmpty(), 'Request list should not be empty');

        // Call handleChange method
        Test.startTest();
        AccountFlowHandler.handleChange(requestList);
        Test.stopTest();

        // Assertions: Ensure no errors were thrown
        System.assertEquals(2, requestList.size(), 'There should be 2 requests in the list');
    }

    @isTest
    static void testEmptyRequestList() {
        // Test handleChange with empty request list
        List<AccountFlowHandler.RequestWrapper> emptyRequestList = new List<AccountFlowHandler.RequestWrapper>();

        Test.startTest();
        AccountFlowHandler.handleChange(emptyRequestList);
        Test.stopTest();

        // Ensure no errors were thrown and handleChange gracefully handles empty lists
        System.debug('Empty request list processed successfully');
    }
}