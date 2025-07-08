/*****
* Created by Saurabh Chandra[03-06-2025]
* Test Class: ContactFlowHandlerTest
* Description: This class is used for creation and updation of Contact for Insight
* Referenced From : Flow on Contact
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
 
****************************************************/

public class ContactFlowHandler {
    public class RequestWrapper{
        @InvocableVariable(required=true)
        public Id contactId;
        @InvocableVariable(required=true)
        public string actionType;
    }
    
    @InvocableMethod
    public static void handleChange(List<RequestWrapper> requests){
        for (RequestWrapper request : requests){
           
            if (request.actionType == 'create'){
                handleCreate(request.contactId);
            } else if(request.actionType == 'update'){
                handleUpdate(request.contactId);
            }
        }
    }

    @future(callout = true)
    public static void handleCreate(string contactId){
        Contact con = [SELECT Id, Addressee__c ,Birthdate ,Email ,Fax ,mm_Created_When__c ,mm_Created_Who__c ,mm_External_Id__c ,mm_Is_Primary_Contact__c ,MobilePhone ,Name ,OtherPhone ,Phone ,Salutation ,Title,Account.mm_INSIGHTS_Id__c, RowVersion__c from Contact where Id = :contactId AND Account.mm_INSIGHTS_Id__c != null LIMIT 1];
        system.debug('sendClientDetails->'+'Create Client');
        InsightAPIHelperContact.sendContactDetails(con,'create', null, null);
    }
    
    @future(callout = true)
    public static void handleUpdate(string contactId){
        string conInsightId = [SELECT Id,mm_External_Id__c  from Contact where Id = :contactId AND Account.mm_INSIGHTS_Id__c != null LIMIT 1].mm_External_Id__c;
        if(!string.isBlank(conInsightId)){
            InsightAPIHelperContact.getContactDetails(conInsightId,contactId);
        }
    }
}