/*****
* Created by Saurabh Chandra[29-05-2025]
* Test Class: AccountFlowHandlerTest
* Description: This class is used for creation and updation of Account for Insight
* Referenced From : Flow on Account
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
 
****************************************************/

public class AccountFlowHandler {
    public class RequestWrapper{
        @InvocableVariable(required=true)
        public Id accountId;
        @InvocableVariable(required=true)
        public string actionType;
    }
    
    @InvocableMethod
    public static void handleChange(List<RequestWrapper> requests){
        if (requests == null || requests.isEmpty()) {
            System.debug('Request list is empty or null.');
            return;
        }
        for (RequestWrapper request : requests){
            if (request.actionType == 'create'){
                handleCreate(request.accountId);
            } else if(request.actionType == 'update'){
                handleUpdate(request.accountId);
            }
        }
    }
   
    @future(callout = true)
    public static void handleCreate(string accId){
        Account acc = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, 
                       Client_Status__pc, mm_ABA_Reference_Number__c, mm_Account_Email__c, mm_Account_Name__c, Website, Industry, 
                       PersonEmail, PersonMobilePhone, Addressee__pc, mm_Addressee__c, mm_Allow_Part_Payments__c, mm_Account_Number__c,
                       FinServ__PrimaryContact__c,PersonTitle, mm_Bank_Name__c, mm_Authorised_Rep__c, mm_Branch__c, mm_Branch_Name__c,  mm_Service_Team__c,
                       mm_Client_Permissions_Groups__c, mm_Code__c, mm_Company_ABN__c, mm_Compliance_Type__c, mm_Created_When__c, AccountNumber,
                       mm_Created_Who__c, mm_INSIGHTS_Id__c, mm_Phone_Other__c, mm_Referrer__c, mm_Standard_Industry_Code__c, mm_Trading_Name__c, User__c, 
                       mm_BSB_Number__c,mm_Current_State__c ,mm_Email_Policy_Documents__c,mm_Client_ID__c,CreatedDate,LastModifiedDate,RowVersion__c from Account where Id = :accId LIMIT 1];
        system.debug('sendClientDetails->'+'Create Client');
        InsightAPIHelper.sendClientDetails(acc,'create', null, null);
    }
    
    @future(callout = true)
    public static void handleUpdate(string accId){        
        string accInsightId = [SELECT Id,mm_INSIGHTS_Id__c from Account where Id = :accId LIMIT 1].mm_INSIGHTS_Id__c;
        if(!string.isBlank(accInsightId)){
            //InsightAPIHelper.getClientDetails(accInsightId,accId);
        }
    }
}