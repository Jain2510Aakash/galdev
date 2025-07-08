@isTest
public with sharing class AutomobileWelcomeScreenCtrlUnitTest 
{
    @isTest static void getCurrentUserTest()
    {
        AutomobileWelcomeScreenCtrl.getCurrentUser();
    }

    @isTest static void getUserPoliciesTest()
    {
        AutomobileWelcomeScreenCtrl.getUserPolicies();
    }

    @isTest static void getDefultAccountTest()
    {
        AutomobileWelcomeScreenCtrl.getDefultAccount();
    }

    /*@isTest static void updateCurrentUserAccountTest()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        Id acc_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurer and Insured Suppliers').getRecordTypeId();
        acc.RecordTypeId = acc_recordtype_id;
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = '01';
        con.AccountId = acc.Id;
        con.Email = UserInfo.getUserEmail();
        insert con;
        AutomobileWelcomeScreenCtrl.updateCurrentUserAccount(System.today(),'Test', 'Test', 'Test',
        con.Id, acc.Id);
    }*/

    @isTest static void getUserCasesTest()
    {
        AutomobileWelcomeScreenCtrl.getUserCases();
    }

    @isTest static void getUserClaimsTest()
    {
        AutomobileWelcomeScreenCtrl.getUserClaims();
    }

    @isTest static void getClaimTypeTest()
    {
        AutomobileWelcomeScreenCtrl.getClaimType();
    }

    @isTest static void getClaimStatusTest()
    {
        AutomobileWelcomeScreenCtrl.getClaimStatus();
    }

    @isTest static void getLossTypeTest()
    {
        AutomobileWelcomeScreenCtrl.getLossType();
    }

    @isTest static void getPoliciyByIdTest()
    {
        try {
            AutomobileWelcomeScreenCtrl.getPoliciyById('12345678909');
        } catch (Exception ex) 
        {
            
        }
        
    }

    @isTest static void getContactsTest()
    {
        AutomobileWelcomeScreenCtrl.getContacts();
    }

    @isTest static void getPolicyTypeTest()
    {
        AutomobileWelcomeScreenCtrl.getPolicyType();
    }

    @isTest static void getPolicyStatusTest()
    {
        AutomobileWelcomeScreenCtrl.getPolicyStatus();
    }

    /*@isTest static void createCaseTest()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        Id acc_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurer and Insured Suppliers').getRecordTypeId();
        acc.RecordTypeId = acc_recordtype_id;
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = '01';
        con.AccountId = acc.Id;
        con.Email = 'test@gmail.com';
        insert con;

        AutomobileWelcomeScreenCtrl.createCase('Test', '12345678', '12345678');
    }*/

    /*@isTest static void createClaimTest()
    {
        Id acc_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurer and Insured Suppliers').getRecordTypeId();
        Account acc = new Account(Name = 'Test JR01', RecordTypeId = acc_recordtype_id);
        insert acc;
        InsurancePolicy policy = new InsurancePolicy();
        policy.Name = 'Test';
        policy.NameInsuredId = acc.Id;
        insert policy;
        AutomobileWelcomeScreenCtrl.createClaim('Notified','Test','Test','Home','10.0', 'Impact',
                                   'Test', 'Test', System.DateTime.Now(),System.DateTime.Now(), acc.Id, policy.Id);
    }*/

    @isTest static void createInsurancePolicyTest()
    {
        
        AutomobileWelcomeScreenCtrl.createInsurancePolicy('Test','','',
        System.DateTime.Now(), '100', '123456778');
    }

    @isTest static void getCaseByIdTest()
    {
        AutomobileWelcomeScreenCtrl.getCaseById('123456789');
    }

    @isTest static void newClaimTest()
    {
        AutomobileWelcomeScreenCtrl.newClaim();
    }

    @isTest static void getContactByIdTest()
    {
        AutomobileWelcomeScreenCtrl.getContactById('123456789');
    }

    /*@isTest static void createContactTest()
    {
        Account acc = new Account();
        acc.Name = 'Test';
        Id acc_recordtype_id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurer and Insured Suppliers').getRecordTypeId();
        acc.RecordTypeId = acc_recordtype_id;
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = '01';
        con.AccountId = acc.Id;
        con.Email = 'test@gmail.com';
        insert con;
        AutomobileWelcomeScreenCtrl.createContact('test', 'test', '12345', '123456', System.today(), con.Id);
    }*/

    @isTest static void createPortalUserTest()
    {
        AutomobileWelcomeScreenCtrl.createPortalUser('test', 'test', '1234568', '1234568', System.today(), 'test@gmail.com');
    }

    @isTest static void getInsurancePolicyAssetByPolicyIdTest()
    {
        AutomobileWelcomeScreenCtrl.getInsurancePolicyAssetByPolicyId('123456789');
    }

    @isTest static void getCustomerPropertyByAssetIdTest()
    {
        AutomobileWelcomeScreenCtrl.getCustomerPropertyByAssetId('123456789');
    }

    @isTest static void fakeTest()
    {
        AutomobileWelcomeScreenCtrl.fakeData();
    }
}