/*****
* Created by Saurabh Chandra[03-06-2025]
* Test Class: InsightAPIHelperContactTest
* Description: This class handles the API for SFDC and Insight for COntact
* Referenced From : ContactFlowHandler
* Change log
*
* Author            Date            Description
* Aakash Jain 		8-July-2025		added settimeout for request and error log fields
* Aakash Jain 	 	11-July-2025	handled fax and phone length
* Aakash Jain 	 	11-July-2025	handled Contact Update API -getting the details for createdwhen and createdwho

* ==============================================================================================================================================================
 
****************************************************/

public class InsightAPIHelperContact {
    
    public static void sendContactDetails(Contact con, string actionType, string rowVersion, Integer parentId) {
        system.debug('con->'+con);
        system.debug('actionType->'+actionType);
        
        if (con == null) {
            return;
        }
        
        system.debug('con->'+con);
        //custom setting
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        
        String endpointPath = '';
        String httpMethod = 'POST';
        string auditId = '';
        String createdWhen = '';
        String createdWho = '';
        String clientId = '';
        String jsonResponse='';
        
        if (actionType == 'create') {
            endpointPath = '/Contact/Create';
            httpMethod = 'POST';
        } else if (actionType == 'update') {
            endpointPath = '/Contact/Update';
            httpMethod = 'POST';
        }
        
        system.debug('endpointPath->'+endpointPath);
        system.debug('httpMethod->'+httpMethod);
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);        
        
        String requestBody = ContactJsonBuilder.generateContactJson(con, actionType, parentId, rowVersion);
        req.setBody(requestBody);
        System.debug('Generated JSON: ' + requestBody);
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('res: ' + res);
            System.debug('Response: ' + res.getBody());
            jsonResponse = res.getBody(); 
            if(res.getStatusCode() == 200){
                Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                
                if (!outerMap.containsKey('Contact')) {
                    System.debug('Error: Contact not found in API response');
                    return;
                }
                
                Map<String, Object> contactMap = (Map<String, Object>) outerMap.get('Contact');
                
                if (actionType == 'create'){
                    try{
                        auditId = string.valueOf(contactMap.get('AuditId'));
                        createdWhen = String.valueOf(contactMap.get('CreatedWhen'));
                        createdWho = String.valueOf(contactMap.get('CreatedWho'));
                        clientId = String.valueOf(contactMap.get('ParentId'));
                        
                        Contact contactToUpdate = new Contact();
                        contactToUpdate.Id = con.id;
                        contactToUpdate.mm_External_Id__c = string.valueOf(auditId);
                        contactToUpdate.mm_Created_When__c = string.valueOf(createdWhen);
                        contactToUpdate.mm_Created_Who__c = string.valueOf(createdWho);
                        contactToUpdate.mm_Client_ID__c = string.valueOf(clientId);
                        update contactToUpdate;
                    }catch(Exception ex){
                        mm_Integration_Log__c log = new mm_Integration_Log__c();
                        log.Contact__c = con.Id;
                        log.Status_Code__c = String.valueOf(res.getStatusCode());
                        log.mm_Error_Description__c = jsonResponse;                        
                        log.Request_Endpoint__c = endpointPath;
                        log.mm_Payload__c =  'requestBody->'+requestBody;
                        log.mm_Log_Time__c = system.now();
                        log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> sendContactDetails';
                        log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                        insert log;
                    }
                }
            } else {
                
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Contact__c = con.Id;
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+requestBody;
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> sendContactDetails';
                insert log;
            }
        } catch (Exception ex) {
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Contact__c = con.Id;
            log.mm_Error_Description__c = jsonResponse;
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody->'+requestBody;   
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> sendContactDetails';
            log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
        }    
    }
    
    public static void getContactDetails(string conInsightId, string contactId){
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        
        String endpointPath = '/Contact/get';
        String httpMethod = 'POST'; 
        String jsonResponse = '';
        
        if(!string.isBlank(conInsightId)){
            HttpRequest req = new HttpRequest();
            req.setMethod(httpMethod);
            req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        	req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        	req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(60000);        

            Map<String, Object> data = new Map<String, Object>();
            
            data.put('Id', conInsightId);
            
            String requestBody = JSON.serialize(data);
            req.setBody(requestBody);
            System.debug('Final Request JSON: ' + requestBody);
            
            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                System.debug('Response: ' + res.getBody());
                jsonResponse = res.getBody(); 

                if(res.getStatusCode() == 200){
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                    Map<String, Object> contact = (Map<String, Object>) result.get('Contact');
                    String rowVersion = (String) contact.get('RowVersion');
                    Integer profileId = (Integer) contact.get('ProfileId');
                    Integer parentId = (Integer) contact.get('ParentId');
                    
                    if(!String.isBlank(rowVersion)){
                        updateContactDetailsOnInsight(jsonResponse, contactId);
                    }
                } else {
                    // Handle API error responses
                    
                    mm_Integration_Log__c log = new mm_Integration_Log__c();
                    log.Contact__c = contactId;
                    log.Status_Code__c = String.valueOf(res.getStatusCode());
                    log.mm_Error_Description__c = jsonResponse;
                    log.Request_Endpoint__c = endpointPath;
                    log.mm_Payload__c =  'requestBody->'+requestBody;
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> getContactDetails';
                    insert log;
                }
                
            } catch (Exception ex) {
                System.debug('Callout Error: ' + ex.getLineNumber());
                System.debug('Callout Error: ' + ex.getMessage());
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Contact__c = contactId;
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+requestBody;   
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> getContactDetails';
                log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                insert log;
            }    
        }
    }
    
    public static void updateContactDetailsOnInsight(string originalJson, String contactId){
        if(String.isBlank(originalJson) || String.isBlank(contactId)){
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Contact__c = contactId;
            log.mm_Error_Description__c = originalJson;
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> updateContactDetailsOnInsight'+'\n\n contactId->'+contactId;
            insert log;
            return;
            
        }
        String endpointPath = '/Contact/Update';
        String httpMethod = 'POST';
        String jsonResponse='';
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);        
        
        Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(originalJson);
        Map<String, Object> contactObj = (Map<String, Object>) parsedResponse.get('Contact');
        String addressee = (String) contactObj.get('Addressee');
        
        Contact con = [SELECT Id, Addressee__c ,Birthdate ,Email ,Fax ,mm_Created_When__c ,mm_Created_Who__c ,mm_External_Id__c ,mm_Is_Primary_Contact__c ,MobilePhone ,Name ,OtherPhone ,Phone ,Salutation ,Title,Account.mm_INSIGHTS_Id__c, RowVersion__c from Contact where Id = :contactId  LIMIT 1];
    
        contactObj.put('IsPrimary', con.mm_Is_Primary_Contact__c);
        if (con.Name != null) contactObj.put('Addressee', con.Name);
        if (con.Salutation != null) contactObj.put('Salutation', con.Salutation);
        if (con.Title != null) contactObj.put('JobTitle', con.Title);
        if (con.OtherPhone != null) contactObj.put('Telephone2', con.OtherPhone);
        if (con.MobilePhone != null) contactObj.put('Mobile', con.MobilePhone);
        
        String phone = con.Phone != null ? con.Phone.trim() : null;
        if (phone != null) {
            phone = phone.length() > 15 ? phone.substring(0, 15) : phone;
            contactObj.put('Telephone', phone);
        }
        String Fax = con.Fax != null ? con.Fax.trim() : null;
        if (Fax != null) {
            Fax = Fax.length() > 15 ? Fax.substring(0, 15) : Fax;
            contactObj.put('Fax', Fax);
        }   
        
        if (con.Email != null) contactObj.put('Email', con.Email);
        if (con.Birthdate != null) contactObj.put('BirthDate', con.Birthdate);
        parsedResponse.put('Contact', contactObj);
        String modifiedJson = JSON.serialize(parsedResponse);
        integer statusCode;
        
        req.setBody(modifiedJson);
        System.debug('Final Update Request JSON: ' + modifiedJson);         
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            statusCode  = res.getStatusCode();
            jsonResponse = res.getBody();
            if(res.getStatusCode() != 200){
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Contact__c = contactId;
                log.Status_Code__c = String.valueOf(statusCode);
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+modifiedJson;   
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> updateContactDetailsOnInsight'+'\n\n contactId->'+contactId;
                insert log;
            }
        }catch (Exception ex) {
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Contact__c = contactId;
            log.Status_Code__c = String.valueOf(statusCode);
            log.mm_Error_Description__c = jsonResponse;
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody->'+modifiedJson;   
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> updateContactDetailsOnInsight'+'\n\n contactId->'+contactId;
            log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
        }  
    }
}