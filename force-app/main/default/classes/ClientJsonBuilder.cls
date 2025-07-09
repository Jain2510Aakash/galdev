/*****
* Created by Saurabh Chandra[29-05-2025]
* Test Class: InsightAPIHelperTest
* Description: Creates a JSON body to be sent for creating client taking reference of Account fields
* Referenced From : InsightAPIHelper
* Change log
*
* Author            Date            Description
* Aakash Jain		9-July-2025		handled branch and client permission group
* ==============================================================================================================================================================
 
****************************************************/

public class ClientJsonBuilder {
    
    public static String generateClientJson(Account acc, string actionType, integer createORupdate, string rowversion, Integer ProfileId) {
        Map<String, Object> client = new Map<String, Object>();
        
        if(acc.BillingStreet != null){
            String billingStreet = acc.BillingStreet;
            List<String> addressParts = billingStreet.split('\n');  // Split by newlines
            String addressLine1 = '';
            String addressLine2 = '';
            String addressLine3 = '';
            Integer maxLength = 40;
            
            if (addressParts.size() > 0) {
                addressLine1 = addressParts[0].trim();
                if (addressLine1.length() > maxLength) {
                    addressLine1 = addressLine1.substring(0, maxLength);
                }
            }
            if (addressParts.size() > 1) {
                addressLine2 = addressParts[1].trim();
                if (addressLine2.length() > maxLength) {
                    addressLine2 = addressLine2.substring(0, maxLength);
                }
            }
            if (addressParts.size() > 2) {
                addressLine3 = addressParts[2].trim();
                if (addressLine3.length() > maxLength) {
                    addressLine3 = addressLine3.substring(0, maxLength);
                }
            }
            
            if (acc.BillingStreet != null) client.put('AddressLine1', addressLine1);
            if (acc.BillingStreet != null) client.put('AddressLine2', addressLine2);
            if (acc.BillingStreet != null) client.put('AddressLine3', addressLine3);
        }
        client.put('Id', createORupdate); 
        
        if (acc.Name != null) client.put('Name', acc.Name);
        if (acc.mm_Trading_Name__c != null) client.put('TradingAs', acc.mm_Trading_Name__c);
        if (acc.mm_Compliance_Type__c != null) client.put('ComplianceTypeName', acc.mm_Compliance_Type__c);
        if (acc.mm_Addressee__c != null) client.put('Addressee', acc.mm_Addressee__c);
        if (acc.mm_Referrer__c != null) client.put('Ref', acc.mm_Referrer__c.left(15)); 
        if (acc.mm_Company_ABN__c != null) client.put('ABN', acc.mm_Company_ABN__c);
        if (acc.FinServ__PrimaryContact__c != null) client.put('Contact', acc.FinServ__PrimaryContact__c);
        if (acc.PersonTitle != null) client.put('JobTitle', acc.PersonTitle);
        if (acc.BillingCity != null) client.put('Suburb', acc.BillingCity);
        if (acc.BillingState != null) client.put('StateName', acc.BillingState);
        if (acc.BillingPostalCode != null) client.put('Postcode', acc.BillingPostalCode.left(4));
        if (acc.BillingCountry != null) client.put('CountryName', acc.BillingCountry);
        if (acc.Phone != null) client.put('Telephone', acc.Phone);
        if (acc.mm_Phone_Other__c != null) client.put('Telephone2', acc.mm_Phone_Other__c);
        if (acc.mm_Account_Email__c != null) client.put('Email', acc.mm_Account_Email__c);
        if (acc.Fax != null) client.put('Fax', acc.Fax);
        if (acc.PersonMobilePhone != null) client.put('Mobile', acc.PersonMobilePhone);
        if (acc.Website != null) client.put('Web', acc.Website);
        if (acc.mm_Account_Name__c != null) client.put('AccountName', acc.mm_Account_Name__c);
        if (acc.AccountNumber != null) client.put('AccountNumber', acc.AccountNumber);
        if (acc.mm_Bank_Name__c != null) client.put('BankName', acc.mm_Bank_Name__c);
        if (acc.mm_Branch_Name__c != null) client.put('BankBranchName', acc.mm_Branch_Name__c);
        if (acc.mm_BSB_Number__c != null) client.put('BSBNumber', acc.mm_BSB_Number__c);
        if (acc.mm_ABA_Reference_Number__c != null) client.put('ABARefNumber', acc.mm_ABA_Reference_Number__c);
        if (acc.mm_Email_Policy_Documents__c != null) client.put('EmailPolicyDocuments', acc.mm_Email_Policy_Documents__c);
        if (acc.Industry != null) client.put('StandardIndustryCodeName', acc.Industry);
        
        integer CountryId;
        Integer stateId;
        Integer BranchId;
        integer RecordPermissionsGroupId;
        integer SalesTeamId;
        integer ServiceTeamId;
        integer StandardIndustryCode;
        integer ComplianceTypeId;
        integer AuthorisedRep1Id;
        integer Category1Id;

        if(acc.BillingCountry != null && InsightMetadataHelper.getMappedId('Account', 'Country', acc.BillingCountry ) != null){
             CountryId = InsightMetadataHelper.getMappedId('Account', 'Country', acc.BillingCountry);
         }else{
             CountryId = InsightMetadataHelper.getMappedId('Account', 'Country', 'Default');
         }
         client.put('CountryId', CountryId);
        
         if(acc.BillingState != null && InsightMetadataHelper.getMappedId('Account', 'State', acc.BillingState ) != null){
             stateId = InsightMetadataHelper.getMappedId('Account', 'State', acc.BillingState );
         }else{
             stateId = InsightMetadataHelper.getMappedId('Account', 'State', 'Default');
         }
         client.put('StateId', stateId);
        
         if(acc.mm_Branch__c  != null ){
             BranchId = integer.valueOf(acc.mm_Branch__c);
         }else{
             BranchId = InsightMetadataHelper.getMappedId('Account', 'Branch', 'Default' );
         }
         client.put('BranchId', BranchId);
        
        if(acc.mm_Client_Permissions_Groups__c  != null ){
             RecordPermissionsGroupId = integer.valueOf(acc.mm_Client_Permissions_Groups__c);
        }else{
             RecordPermissionsGroupId = InsightMetadataHelper.getMappedId('Account', 'Client Permissions Group', 'Default');
         }
         client.put('RecordPermissionsGroupId', RecordPermissionsGroupId);

        if(acc.User__c != null && ClientJsonBuilder.getSalesServiceTeamIdSF(acc.User__c).Sales_Team_Id__c != null ){
             SalesTeamId = Integer.valueOf(ClientJsonBuilder.getSalesServiceTeamIdSF(acc.User__c).Sales_Team_Id__c);
         }else{
             SalesTeamId = InsightMetadataHelper.getMappedId('Account','SalesTeamId','Default');
         }
         client.put('SalesTeamId',SalesTeamId);
         
         if(acc.mm_Service_Team__c != null && ClientJsonBuilder.getSalesServiceTeamIdSF(acc.mm_Service_Team__c).Service_Team_Id__c != null){
             ServiceTeamId =  Integer.valueOf(ClientJsonBuilder.getSalesServiceTeamIdSF(acc.mm_Service_Team__c).Service_Team_Id__c);
         }else{
             ServiceTeamId = InsightMetadataHelper.getMappedId('Account','ServiceTeamId','Default');
         }
         client.put('ServiceTeamId',ServiceTeamId);
        
        ProfileId = InsightMetadataHelper.getMappedId('Account','ProfileId','Default');
        client.put('ProfileId', ProfileId); 
        
        StandardIndustryCode = InsightMetadataHelper.getMappedId('Account','StandardIndustryCode','Default');
        client.put('StandardIndustryCode', StandardIndustryCode);   
        
        ComplianceTypeId = InsightMetadataHelper.getMappedId('Account','ComplianceTypeId','Default');
        client.put('ComplianceTypeId', ComplianceTypeId);    
        
        AuthorisedRep1Id = InsightMetadataHelper.getMappedId('Account','AuthorisedRep1Id','Default');
        client.put('AuthorisedRep1Id', AuthorisedRep1Id);    
        
        Category1Id = InsightMetadataHelper.getMappedId('Account','Category1Id','Default');
        client.put('Category1Id', Category1Id);    
       
        
        // hardcoded values for CBN testing

        client.put('CountryId', 14);
        client.put('StateId', 7);
        client.put('BranchId', 4);
        client.put('RecordPermissionsGroupId', 4);
        client.put('SalesTeamId', 12);
        client.put('ServiceTeamId', 11);
        client.put('StandardIndustryCode', 1);
        client.put('BranchId', 4);
        client.put('ComplianceTypeId', 1);
        client.put('AuthorisedRep1Id', 142);    
        client.put('Category1Id', 3);    

        
        Map<String, Object> wrapper = new Map<String, Object>{
            'Client' => client
                };
        system.debug('wrapper->'+wrapper);
        return JSON.serialize(wrapper);
    }
    public static user getSalesServiceTeamIdSF(string userId){
        system.debug('getSalesServiceTeamIdSF->   '+' userId ->'+userId );
        if(string.isBlank(userId)){
            return null;
        }
        List<User> userList = [Select ID,PolicyTeamId__c,Service_Team_Id__c,Sales_Team_Id__c From User where id =: userId limit 1];
        system.debug('userList->'+userList);
        
        if(!userList.isEmpty()){
            return userList[0];
        }else{
            return null;
        }
    }
}