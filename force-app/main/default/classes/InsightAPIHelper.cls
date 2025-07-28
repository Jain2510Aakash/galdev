/*****
* Created by Saurabh Chandra[27-05-2025]
* Test Class: InsightAPIHelperTest
* Description: This class handles the API for SFDC and Insight for Account
* Referenced From : AccountFlowHandler
* Change log
*
* Author            Date            Description
* Aakash Jain 		8-July-2025		added settimeout for request and error log fields
* Aakash Jain		9-July-2025		handled branch and client permission group
* Aakash Jain 	 	11-July-2025	handled fax and phone length
* Aakash Jain 	 	14-July-2025	Added check for StandardIndustryCode and StandardIndustryCodeName for update API, if these both are not null then only proceed for update  

* ==============================================================================================================================================================

****************************************************/

public class InsightAPIHelper {
    public static void sendClientDetails(Account acc, string actionType, string rowVersion, Integer ProfileId) {
        system.debug('acc->'+acc);
        system.debug('actionType->'+actionType);
        
        if (acc == null) {
            return;
        }
        
        system.debug('acc->'+acc);
        //custom setting
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        
        String endpointPath = '';
        String httpMethod = 'POST'; 
        integer CreateORUpdateId = 0;
        
        Integer auditId =0;
        String createdWhen = '';
        String createdWho = '';
        String standardIndustryCode = '';
        String jsonResponse = '';
        
        if (actionType == 'create') {
            endpointPath = '/Client/Create';
            httpMethod = 'POST';
        } else if (actionType == 'update') {
            endpointPath = '/Client/Update';
            httpMethod = 'POST';
            if(acc.mm_INSIGHTS_Id__c != null)
                CreateORUpdateId = integer.ValueOf(acc.mm_INSIGHTS_Id__c);
        }
        system.debug('endpointPath->'+endpointPath);
        system.debug('httpMethod->'+httpMethod);
        system.debug('CreateORUpdateId-> ' + CreateORUpdateId);
        system.debug('AccountId-> ' + acc.Id);
        
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c); 
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);        
        String requestBody = ClientJsonBuilder.generateClientJson(acc, actionType, CreateORUpdateId, rowVersion, ProfileId);
        req.setBody(requestBody);
        System.debug('Final Request JSON: ' + requestBody);
        if(insightAPI.isEmpty()) {
            System.debug('Custom Setting Insight_API_Details__c is empty!');
            return;
        }
        
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response: ' + res.getBody());
            jsonResponse = res.getBody();
            if(res.getStatusCode() == 200){
                Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                Map<String, Object> clientMap = (Map<String, Object>) outerMap.get('Client');
                system.debug('client ==> ' + clientMap);
                if (actionType == 'create') 
                {
                    try{
                        auditId = Integer.valueOf(clientMap.get('AuditId'));
                        createdWhen = (String) clientMap.get('CreatedWhen');
                        createdWho = (String) clientMap.get('CreatedWho');
                        standardIndustryCode = (String) clientMap.get('StandardIndustryCode');
                        Account accToUpdate = new Account();
                        accToUpdate.Id = acc.id;
                        accToUpdate.mm_INSIGHTS_Id__c = string.valueOf(auditId);
                        accToUpdate.mm_Created_When__c = createdWhen;
                        accToUpdate.mm_Created_Who__c = createdWho;
                        accToUpdate.mm_Standard_Industry_Code__c = standardIndustryCode;
                        update accToUpdate;
                    }catch(Exception ex){
                        mm_Integration_Log__c log = new mm_Integration_Log__c();
                        log.Account__c = acc.Id;
                        log.Status_Code__c = String.valueOf(res.getStatusCode());
                        log.mm_Error_Description__c = jsonResponse;
                        log.Request_Endpoint__c = endpointPath;
                        log.mm_Payload__c =  'requestBody->'+requestBody;
                        log.mm_Log_Time__c = system.now();
                        log.mm_Failing_Component__c = 'InsightAPIHelper <-> sendClientDetails';
                        log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                        insert log;
                    }
                }
            }else {
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Account__c = acc.Id;
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+requestBody;
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'InsightAPIHelper <-> sendClientDetails';
                insert log;
            }
            
        } catch (Exception ex) {
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Account__c = acc.Id;
            log.mm_Error_Description__c = jsonResponse;
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody->'+requestBody;   
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'InsightAPIHelper <-> sendClientDetails';
            log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
        }    
    }
    
    public static void getClientDetails(string accInsightId, string accountId){
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        
        String endpointPath = '/Client/get';
        String httpMethod = 'POST'; 
        String jsonResponse = '';
        
        if(!string.isBlank(accInsightId)){
            HttpRequest req = new HttpRequest();
            req.setMethod(httpMethod);
            req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
            req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
            req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(60000);
            Map<String, Object> data = new Map<String, Object>();
            
            data.put('Id', accInsightId);
            
            String requestBody = JSON.serialize(data);
            req.setBody(requestBody);
            System.debug('Final Request JSON: ' + requestBody);
            
            Http http = new Http();
            try {
                System.debug('req: ' + req);
                
                HttpResponse res = http.send(req);
                System.debug('Response: ' + res.getBody());
                jsonResponse = res.getBody(); 
                if(res.getStatusCode() == 200){
                    updateClientDetailsOnInsight(jsonResponse, accountId);
                } else {
                    mm_Integration_Log__c log = new mm_Integration_Log__c();
                    log.Account__c = accountId;
                    log.Status_Code__c = String.valueOf(res.getStatusCode());
                    log.mm_Error_Description__c = jsonResponse;
                    log.Request_Endpoint__c = endpointPath;
                    log.mm_Payload__c =  'requestBody->'+requestBody;   
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'InsightAPIHelper <-> getClientDetails';
                    insert log;
                }
                
            } catch (Exception ex) {
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Account__c = accountId;
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+requestBody;   
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'InsightAPIHelper <-> getClientDetails';
                log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                insert log;
            }    
        }
    }
    public static void updateClientDetailsOnInsight(String originalJson, String accountId){
        if(String.isBlank(originalJson) || string.isBlank(accountId)){
            return ;
        }
        
        List<Account> accountList = [Select Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone, Fax, 
                                     Client_Status__pc, mm_ABA_Reference_Number__c, mm_Account_Email__c, mm_Account_Name__c, Website, Industry, 
                                     PersonEmail, PersonMobilePhone, Addressee__pc, mm_Addressee__c, mm_Allow_Part_Payments__c, mm_Account_Number__c,
                                     FinServ__PrimaryContact__c,PersonTitle, mm_Bank_Name__c, mm_Authorised_Rep__c, mm_Branch__c, mm_Branch_Name__c, 
                                     mm_Client_Permissions_Groups__c, mm_Code__c, mm_Company_ABN__c, mm_Compliance_Type__c, mm_Created_When__c, 
                                     mm_Created_Who__c, mm_INSIGHTS_Id__c, mm_Phone_Other__c, mm_Referrer__c, mm_Standard_Industry_Code__c, mm_Trading_Name__c, User__c, 
                                     mm_BSB_Number__c,mm_Current_State__c ,mm_Email_Policy_Documents__c,mm_Client_ID__c,CreatedDate,LastModifiedDate,RowVersion__c,mm_Service_Team__c from Account Where Id =: accountId limit 1];
        
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        String endpointPath = '/Client/update';
        String httpMethod = 'POST'; 
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(originalJson);
        Map<String, Object> client = (Map<String, Object>) parsedResponse.get('Client');
       
        if(client.get('StandardIndustryCode') != null && client.get('StandardIndustryCodeName') != null){
            if(accountList[0].BillingStreet != null){
                String billingStreet = accountList[0].BillingStreet;
                List<String> addressParts = billingStreet.split('\n');  
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
                
                client.put('AddressLine1', addressLine1);
                client.put('AddressLine2', addressLine2);
                client.put('AddressLine3', addressLine3);
            }
            
            if (accountList[0].Name != null) client.put('Name', accountList[0].Name);
            if (accountList[0].mm_Trading_Name__c != null) client.put('TradingAs', accountList[0].mm_Trading_Name__c);
            if (accountList[0].mm_Compliance_Type__c != null) client.put('ComplianceTypeName', accountList[0].mm_Compliance_Type__c);
            if (accountList[0].mm_Addressee__c != null) client.put('Addressee', accountList[0].mm_Addressee__c);
            if (accountList[0].mm_Referrer__c != null) client.put('Ref', accountList[0].mm_Referrer__c.left(15)); 
            if (accountList[0].mm_Company_ABN__c != null) client.put('ABN', accountList[0].mm_Company_ABN__c);
            if (accountList[0].FinServ__PrimaryContact__c != null) client.put('Contact', accountList[0].FinServ__PrimaryContact__c);
            if (accountList[0].PersonTitle != null) client.put('JobTitle', accountList[0].PersonTitle);        
            if (accountList[0].BillingCity != null) client.put('Suburb', accountList[0].BillingCity);
            if (accountList[0].BillingState != null) client.put('StateName', accountList[0].BillingState);
            if (accountList[0].BillingPostalCode != null) client.put('Postcode', accountList[0].BillingPostalCode.left(4));
            if (accountList[0].BillingCountry != null) client.put('CountryName', accountList[0].BillingCountry);
            String phone = accountList[0].Phone != null ? accountList[0].Phone.trim() : null;
            if (phone != null) {
                phone = phone.length() > 15 ? phone.substring(0, 15) : phone;
                client.put('Telephone', phone);
            }
            String Fax = accountList[0].Fax != null ? accountList[0].Fax.trim() : null;
            if (Fax != null) {
                Fax = Fax.length() > 15 ? Fax.substring(0, 15) : Fax;
                client.put('Fax', Fax);
            }         
            if (accountList[0].mm_Phone_Other__c != null) client.put('Telephone2', accountList[0].mm_Phone_Other__c);
            if (accountList[0].mm_Account_Email__c != null) client.put('Email', accountList[0].mm_Account_Email__c);
            if (accountList[0].PersonMobilePhone != null) client.put('Mobile', accountList[0].PersonMobilePhone);
            if (accountList[0].Website != null) client.put('Web', accountList[0].Website);
            if (accountList[0].mm_Account_Name__c != null) client.put('AccountName', accountList[0].mm_Account_Name__c);
            if (accountList[0].mm_Account_Number__c != null) client.put('AccountNumber', accountList[0].mm_Account_Number__c);
            if (accountList[0].mm_Bank_Name__c != null) client.put('BankName', accountList[0].mm_Bank_Name__c);
            if (accountList[0].mm_Branch_Name__c != null) client.put('BankBranchName', accountList[0].mm_Branch_Name__c);
            if (accountList[0].mm_BSB_Number__c != null) client.put('BSBNumber', accountList[0].mm_BSB_Number__c);
            if (accountList[0].mm_ABA_Reference_Number__c != null) client.put('ABARefNumber', accountList[0].mm_ABA_Reference_Number__c);
            if (accountList[0].mm_Email_Policy_Documents__c != null) client.put('EmailPolicyDocuments', accountList[0].mm_Email_Policy_Documents__c);
            // if (acc.mm_Code__c != null) client.put('ClientCode', acc.mm_Code__c);

            integer CountryId;
            Integer stateId;
            Integer BranchId;
            integer RecordPermissionsGroupId;
            integer SalesTeamId;
            integer ServiceTeamId;
            
            if(accountList[0].BillingCountry != null && InsightMetadataHelper.getMappedId('Account', 'Country', accountList[0].BillingCountry ) != null){
                CountryId = InsightMetadataHelper.getMappedId('Account', 'Country', accountList[0].BillingCountry);
            }else{
                CountryId = InsightMetadataHelper.getMappedId('Account', 'Country', 'Default');
            }
            client.put('CountryId', CountryId);
            
            if(accountList[0].BillingState != null && InsightMetadataHelper.getMappedId('Account', 'State', accountList[0].BillingState ) != null){
                stateId = InsightMetadataHelper.getMappedId('Account', 'State', accountList[0].BillingState );
            }else{
                stateId = InsightMetadataHelper.getMappedId('Account', 'State', 'Default');
            }
            client.put('StateId', stateId);
            
            if(accountList[0].mm_Branch__c  != null ){
                BranchId = integer.valueOf(accountList[0].mm_Branch__c);
            }else{
                BranchId = InsightMetadataHelper.getMappedId('Account', 'Branch', 'Default' );
            }
            client.put('BranchId', BranchId);
            
            if(accountList[0].mm_Client_Permissions_Groups__c  != null ){
                RecordPermissionsGroupId = integer.valueOf(accountList[0].mm_Client_Permissions_Groups__c);
            }else{
                RecordPermissionsGroupId = InsightMetadataHelper.getMappedId('Account', 'Client Permissions Group', 'Default'  );
            }
            client.put('RecordPermissionsGroupId', RecordPermissionsGroupId);
            
            if(accountList[0].User__c != null && ClientJsonBuilder.getSalesServiceTeamIdSF(accountList[0].User__c).Sales_Team_Id__c != null ){
                SalesTeamId = Integer.valueOf(ClientJsonBuilder.getSalesServiceTeamIdSF(accountList[0].User__c).Sales_Team_Id__c);
            }else{
                SalesTeamId = InsightMetadataHelper.getMappedId('Account','SalesTeamId','Default');
            }
            client.put('SalesTeamId',SalesTeamId);
            
            if(accountList[0].mm_Service_Team__c != null && ClientJsonBuilder.getSalesServiceTeamIdSF(accountList[0].mm_Service_Team__c).Service_Team_Id__c != null){
                ServiceTeamId =  Integer.valueOf(ClientJsonBuilder.getSalesServiceTeamIdSF(accountList[0].mm_Service_Team__c).Service_Team_Id__c);
            }else{
                ServiceTeamId = InsightMetadataHelper.getMappedId('Account','ServiceTeamId','Default');
            }
            client.put('ServiceTeamId',ServiceTeamId);
            
            // hardcoded values for CBN testing
            /*client.put('CountryId', 14);
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
			*/  
                        
            parsedResponse.put('Client', client);
            String modifiedJson = JSON.serialize(parsedResponse);
            
            req.setBody(modifiedJson);
            System.debug('Final Update Request JSON: ' + modifiedJson);
            
            integer statusCode;
            string jsonResponse;
            
            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                statusCode  = res.getStatusCode();
                jsonResponse = res.getBody();
                if(res.getStatusCode() != 200){
                    mm_Integration_Log__c log = new mm_Integration_Log__c();
                    log.Account__c = accountId;
                    log.Status_Code__c = String.valueOf(statusCode);
                    log.mm_Error_Description__c = jsonResponse;
                    log.Request_Endpoint__c = endpointPath;
                    log.mm_Payload__c =  'requestBody->'+modifiedJson;   
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'InsightAPIHelper <-> updateClientDetailsOnInsight';
                    insert log;
                }
            }catch (Exception ex) {
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Account__c = accountId;
                log.Status_Code__c = String.valueOf(statusCode);
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+modifiedJson;   
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'InsightAPIHelper <-> updateClientDetailsOnInsight';
                log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                insert log;
            } 
        }
        
    }
}