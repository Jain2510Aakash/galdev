@isTest
private class MaxoCTISearchTest {
   @isTest static void testGetUserExtension() {
        // Create a test user with a Maxo__Maxo_Extension__c value
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            Username = 'testuserformaxotestgetuser@example.com',
            CommunityNickname = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CTI_Extension__c = '1234',
            ProfileId = UserInfo.getProfileId()
        );
        insert testUser;

        // Call the getUserExtension function with the test user's ID
        String extension = MaxoCTISearch.getUserExtension(testUser.Id);

        // Verify that the function returns the correct extension value
        System.assertEquals('1234', extension);
    }

    @isTest static void testGetKey() {
        // Create a test Maxo__Maxo_API__c record with a Maxo__API_Key__c value
        CTI_API__c testMaxoAPI = new CTI_API__c(
            API_Identifier__c = 'testApiKey',
            Name = 'testAPI'
        );
        insert testMaxoAPI;

        // Call the getKey function
        String apiKey = MaxoCTISearch.getKey();

        // Verify that the function returns the correct API key value
        System.assertEquals('{"UserID":"'+UserInfo.getUserId()+'","key":"testApiKey"}', apiKey);
    }

    @isTest static void testGetContacts_positive() {
        // Insert test user
        Contact testContact = new Contact(
            Email = 'testuser@example.com',
            Phone = '0415000000',
            FirstName = 'Test',
            LastName = 'User'
        );
        insert testContact;

        // Call search method to find newly inserted user
        String searchVal = '0415000000';
        String result = MaxoCTISearch.getContacts(searchVal,'testID');

        Map<String, Object> mappedResult = 
            (Map<String, Object>)
                JSON.deserializeUntyped(result);

        List<Object> contactsList = 
            (List<Object>)mappedResult.get('Contacts');

        // Check that only one user was returned 
        System.assertEquals(1, contactsList.size());

        // Check that the 'term' field is what we sent through originally
        System.assertEquals('0415000000', mappedResult.get('term'));

        // Pull the contact from the JSON result
        Map<String, Object> resultContact = 
            (Map<String, Object>)contactsList[0];
        
        // Make sure the contact name field is an aggregate as we expect
        System.assertEquals('Test User', resultContact.get('Name'));

        // Make sure the contact email field is correct
        System.assertEquals('testuser@example.com', resultContact.get('Email'));
    }

    @isTest static void testGetContacts_negative() {
        // Insert two test users
        Contact testContact = new Contact(
            Email = 'testuser@example.com',
            Phone = '0415000000',
            FirstName = 'Test',
            LastName = 'User'
        );
        insert testContact;

        Contact testContact2 = new Contact(
            Email = 'testuser2@example.com',
            Phone = '0415000123',
            FirstName = 'Second',
            LastName = 'Testuser'
        );
        insert testContact2;

        // Search that should return no results
        String searchVal = '0415999999';
        String result = MaxoCTISearch.getContacts(searchVal,'testID');

        Map<String, Object> mappedResult = 
            (Map<String, Object>)
                JSON.deserializeUntyped(result);

        List<Object> contactsList = 
            (List<Object>)mappedResult.get('Contacts');

        // Ensure the search returned no results
        System.assertEquals(0, contactsList.size());

        // Ensure the term is as we expect
        System.assertEquals('0415999999', mappedResult.get('term'));
    }

    @isTest static void testGetAllAccounts_positive() {
        // Insert single account
        Account testAccount = new Account(
            Name = 'testAccountSolo'
        );
        insert testAccount;

        String result = MaxoCTISearch.getAllAccounts();

        List<Object> mappedResult = 
            (List<Object>)JSON.deserializeUntyped(result);

        // Check for only one result
        System.assertEquals(1, mappedResult.size());

        Map<String, Object> resultAccount = 
            (Map<String, Object>)mappedResult[0];

        // Ensure the name matches what we just inserted
        System.assertEquals('testAccountSolo', resultAccount.get('Name'));

        // Insert 200 new accounts
        List<Account> testBulkAccounts = new List<Account>();
        for(integer i=0; i<200; i++) {
            testBulkAccounts.add( new Account(Name = 'testAccount' + i) );
        }
        insert testBulkAccounts;

        System.Debug('testBulkAccounts size: ' + testBulkAccounts.size());

        String bulkResult = MaxoCTISearch.getAllAccounts();

        List<Object> mappedBulkResult = 
            (List<Object>)JSON.deserializeUntyped(bulkResult);

        // Ensure number of accounts returned = 201 (200 plus the one we inserted earlier)
        System.assertEquals(201, mappedBulkResult.size());
    }

    @isTest static void testGetAllAccounts_negative() {

        String result = MaxoCTISearch.getAllAccounts();

        List<Object> mappedResult = 
            (List<Object>)JSON.deserializeUntyped(result);

        // Check for empty result set
        System.assertEquals(0, mappedResult.size());
    }
}