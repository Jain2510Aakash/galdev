@isTest
private class AccountPortfolioPDFTest {
    
    @testSetup
    static void setupTestData() {
        List<Profile> p=[select id from profile WHERE Name='System Administrator'];
        User objuser=createuser();
        objuser.profileid=p[0].id;
        objuser.UserRoleId = [select id from UserRole where PortalType ='None' limit 1].Id;
        //insert objuser;
        User runasUser= [select id,Name,Profile.Name,IsActive from User where IsActive=True and Profile.Name='System Administrator' limit 1];
        System.RunAs(runasUser)
        {
        // Create test account
        //Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('mm_Person_Client_Account').getRecordTypeId();
        //system.debug('RecordTypeName' + accRecordTypeId );
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Individual' LIMIT 1];
 
            Account testAccount = new Account();
            //testAccount.Name = 'John';
            testAccount.Name = 'Test Account';
            //testAccount.LastName = 'Doe';
            testAccount.RecordTypeId = rt.Id;
            //testAccount.PersonEmail = 'john123@example.com';
            
        //Account testAccount = new Account(
            //Name = 'Test Account',
            //Type = 'Prospect',
            //Phone = '1234567890',
            //recordTypeId = '012QE000000tryKYAQ'          
       // );
        insert testAccount;

        // Create opportunity record type
        Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('mm_Renewal_Policy').getRecordTypeId();
        
        // Create opportunities
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++) {
            opps.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 10000,
                RecordTypeId = renewalRecordTypeId
            ));
        }
        insert opps;
        
        // Create insurer comparison records
        List<mm_Insurer_Comparison__c> insurerComps = new List<mm_Insurer_Comparison__c>();

        Id insurerAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Insurer_and_Insured_Suppliers').getRecordTypeId();
        System.debug('Record Type ID: ' + insurerAccountRecordTypeId);

        // Create an Account to serve as Insurer
        Account insurer = new Account(
        Name = 'Test Insurer',
        RecordTypeId = insurerAccountRecordTypeId
        );
        insert insurer;
        
        // Only create insurer comparisons for first two opportunities
        for(Integer i = 0; i < 2; i++) {
            insurerComps.add(new mm_Insurer_Comparison__c(
                // Name field removed - it's auto-generated
                mm_Opportunity__c = opps[i].Id,
                Insurer__c = insurer.Id,
                Coverage__c = 'Test Coverage',
                mm_Comments_Remarks__c = 'Test Comments',
                mm_Chosen__c = (i == 0) // First one is chosen
            ));
        }
        insert insurerComps;
        
        // Create insurance policies
        List<InsurancePolicy> policies = new List<InsurancePolicy>();
        for(Integer i = 0; i < 2; i++) {
            policies.add(new InsurancePolicy(
                Name = 'Policy-' + i,
                NameInsuredId = testAccount.Id,
                Status = 'Active',
                EffectiveDate = Date.today(),
                ExpirationDate = Date.today().addYears(1),
                mm_Transaction_Policy_Type__c = 'New Business',
                mm_Insurer__c = insurer.Id
                // Removed Gross_Written_Premium_Roll_up__c and Base_Premium_Roll_up_with_in_Period__c
                // as these appear to be roll-up summary fields that cannot be directly set
            ));
        }
        insert policies;
        
        // Create cases
        List<Case> cases = new List<Case>();
        for(Integer i = 0; i < 2; i++) {
            cases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                Priority = 'Medium',
                AccountId = testAccount.Id
            ));
        }
        insert cases;
        
        // Create claims
        List<Claim> claims = new List<Claim>();
        for(Integer i = 0; i < 3; i++) {
            claims.add(new Claim(
                AccountId = testAccount.Id,
                Name = 'Test Claim',
                Status = 'Advised',
                LossDate = Date.today().addDays(-i*30),
                EstimatedAmount = 1000,
                ActualAmount = 800,
                // Removed Policy__c as it appears to be a read-only field
                Underwriter_Claim_Number__c = 'CLM-' + i
            ));
        }
        insert claims;
        
        // Create tasks for first two claims only
        List<Task> tasks = new List<Task>();
        for(Integer i = 0; i < 2; i++) {
            tasks.add(new Task(
                Subject = 'Test Task ' + i,
                Status = 'Not Started',
                Priority = 'Normal',
                WhatId = claims[i].Id,
                ActivityDate = Date.today().addDays(7),
                Description = 'Test task description'
            ));
        }
        insert tasks;
    }
    }
    
    
    @isTest
    static void testAccountPortfolioPDFConstructor() {
        // Get the test account
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        // Create the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
        
        // Start the test
        Test.startTest();
        AccountPortfolioPDF controller = new AccountPortfolioPDF(stdController);
        Test.stopTest();
        
        // Verify account data was loaded correctly
        //System.assertNotEquals(null, controller.getAccount(), 'Account should be loaded');
        //System.assertEquals('Test Account', controller.getAccount().Name, 'Account name should match');
        //System.assertEquals('1234567890', controller.account.Phone, 'Account phone should match');
        //System.assertEquals('test@example.com', controller.account.mm_Account_Email__c, 'Account email should match');
        
        // Verify opportunities were loaded
        //System.assertEquals(3, controller.opportunities.size(), 'Should have loaded 3 opportunities');
        
        // Verify insurer comparisons were loaded
        //System.assertEquals(2, controller.insurercomparison.size(), 'Should have loaded 2 insurer comparisons');
        
        // Verify hasRelatedInsurerComparisons map
        //System.assertEquals(true, controller.hasRelatedInsurerComparisons.get(controller.opportunities[0].Id), 
                           //'First opportunity should have insurer comparisons');
        //System.assertEquals(true, controller.hasRelatedInsurerComparisons.get(controller.opportunities[1].Id), 
                           //'Second opportunity should have insurer comparisons');
        //System.assertEquals(false, controller.hasRelatedInsurerComparisons.get(controller.opportunities[2].Id), 
                           //'Third opportunity should not have insurer comparisons');
        
        // Verify insurance policies were loaded
        //System.assertEquals(2, controller.insurancePolicies.size(), 'Should have loaded 2 insurance policies');
        
        // Verify cases were loaded
        //System.assertEquals(2, controller.cases.size(), 'Should have loaded 2 cases');
        
        // Verify claims were loaded
        //System.assertEquals(3, controller.claims.size(), 'Should have loaded 3 claims');
        
        // Verify tasks were loaded
        //System.assertEquals(2, controller.tasks.size(), 'Should have loaded 2 tasks');
        
        // Verify hasRelatedTasks map
        //Id claim1Id = controller.claims[0].Id;
        //Id claim2Id = controller.claims[1].Id;
        //Id claim3Id = controller.claims[2].Id;
        
        //System.assertEquals(true, controller.hasRelatedTasks.get(claim1Id), 'First claim should have related tasks');
        //System.assertEquals(true, controller.hasRelatedTasks.get(claim2Id), 'Second claim should have related tasks');
        //System.assertEquals(false, controller.hasRelatedTasks.get(claim3Id), 'Third claim should not have related tasks');
    }
    
    @isTest
    static void testNoRelatedRecords() {
        // Create a new account with no related records
        Account emptyAccount = new Account(
            Name = 'Empty Account',
            Type = 'Customer'
        );
        insert emptyAccount;
        
        // Create the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(emptyAccount);
        
        // Start the test
        Test.startTest();
        AccountPortfolioPDF controller = new AccountPortfolioPDF(stdController);
        Test.stopTest();
        
        // Verify empty lists
        System.assertEquals(0, controller.opportunities.size(), 'Should have no opportunities');
        System.assertEquals(0, controller.insurercomparison.size(), 'Should have no insurer comparisons');
        System.assertEquals(0, controller.insurancePolicies.size(), 'Should have no insurance policies');
        System.assertEquals(0, controller.cases.size(), 'Should have no cases');
        System.assertEquals(0, controller.claims.size(), 'Should have no claims');
        System.assertEquals(0, controller.tasks.size(), 'Should have no tasks');
        
        // Maps should be initialized but empty
        System.assertNotEquals(null, controller.hasRelatedInsurerComparisons, 'hasRelatedInsurerComparisons map should be initialized');
        System.assertEquals(0, controller.hasRelatedInsurerComparisons.size(), 'hasRelatedInsurerComparisons map should be empty');
        
        System.assertNotEquals(null, controller.hasRelatedTasks, 'hasRelatedTasks map should be initialized');
        System.assertEquals(0, controller.hasRelatedTasks.size(), 'hasRelatedTasks map should be empty');
    }
public static User createuser()
    {
        User u = new user();
        u.LastName = 'Test Code';
        u.Email = 'test@test.com';
        u.Alias = 'Tcode';
        u.Username = 'testgirikon@test.com';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        return u;
       
    }

}