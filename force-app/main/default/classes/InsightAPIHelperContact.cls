/*****
* Created by Saurabh Chandra[03-06-2025]
* Test Class: InsightAPIHelperContactTest
* Description: This class handles the API for SFDC and Insight for COntact
* Referenced From : ContactFlowHandler
* Change log
*
* Author            Date            Description
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
        List<insurex__c> insurexCS = insurex__c.getall().values();
        
        String endpointPath = '';
        String httpMethod = 'POST';
        string auditId = '';
        String createdWhen = '';
        String createdWho = '';
        String clientId = '';
        
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
        req.setEndpoint(insurexCS[0].endpoint__c + endpointPath);
        req.setHeader('INSIGHT-USERNAME', insurexCS[0].insightUsername__c);
        req.setHeader('INSIGHT-PASSWORD', insurexCS[0].insightPassword__c);
        req.setHeader('Content-Type', 'application/json');
        
        String requestBody = ContactJsonBuilder.generateContactJson(con, actionType, parentId, rowVersion);
        req.setBody(requestBody);
        System.debug('Generated JSON: ' + requestBody);
        string response;
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('res: ' + res);
            System.debug('Response: ' + res.getBody());
            response =  res.getBody();
            if(res.getStatusCode() == 200){
                String jsonResponse = res.getBody(); 
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
                        log.mm_Error_Description__c = res.getStatus();
                        log.mm_Payload__c = requestBody;
                        insert log;
                    }
                }
            } else {
                system.debug('error here--');
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = res.getStatus();
                log.mm_Payload__c = requestBody;
                insert log;
                
                
                
                /*
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Contact__c = con.Id;
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = jsonResponse;
                log.mm_Payload__c = 'endpointPath ->'+endpointPath+'\n\n requestBody->'+requestBody;
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'InsightAPIHelperContact <-> sendContactDetails';
                log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                insert log;
                */
            }
            
        } catch (Exception ex) {
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Contact__c = con.Id;
            log.mm_Error_Description__c = ex.getMessage();
            log.mm_Payload__c = requestBody +'\n\n response ->'+response;
            try {
                insert log;
            }catch (Exception innerEx) {
                System.debug('Callout Error: ' + innerEx.getMessage());
            }
        }    
    }
    
    public static void getContactDetails(string conInsightId, string contactId){
        List<insurex__c> insurexCS = insurex__c.getall().values();
        
        String endpointPath = '/Contact/get';
        String httpMethod = 'POST'; 
        
        if(!string.isBlank(conInsightId)){
            HttpRequest req = new HttpRequest();
            req.setMethod(httpMethod);
            req.setEndpoint(insurexCS[0].endpoint__c + endpointPath);
            req.setHeader('INSIGHT-USERNAME', insurexCS[0].insightUsername__c);
            req.setHeader('INSIGHT-PASSWORD', insurexCS[0].insightPassword__c);
            req.setHeader('Content-Type', 'application/json');
            
            Map<String, Object> data = new Map<String, Object>();
            
            data.put('Id', conInsightId);
            
            String requestBody = JSON.serialize(data);
            req.setBody(requestBody);
            System.debug('Final Request JSON: ' + requestBody);
            
            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                System.debug('Response: ' + res.getBody());
                if(res.getStatusCode() == 200){
                    String jsonResponse = res.getBody(); 
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                    Map<String, Object> contact = (Map<String, Object>) result.get('Contact');
                    String rowVersion = (String) contact.get('RowVersion');
                    Integer profileId = (Integer) contact.get('ProfileId');
                    Integer parentId = (Integer) contact.get('ParentId');
                    
                    if(!String.isBlank(rowVersion)){
                        updateContactDetailsOnInsight(rowVersion,parentId, contactId);
                    }
                } else {
                    // Handle API error responses
                    mm_Integration_Log__c log = new mm_Integration_Log__c();
                    log.Contact__c = contactId;
                    log.Status_Code__c = String.valueOf(res.getStatusCode());
                    log.mm_Error_Description__c = res.getStatus();
                    log.mm_Payload__c = requestBody;
                    insert log;
                }
                
            } catch (Exception ex) {
                System.debug('Callout Error: ' + ex.getLineNumber());
                System.debug('Callout Error: ' + ex.getMessage());
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Contact__c = contactId;
                log.mm_Error_Description__c = ex.getMessage();
                log.mm_Payload__c = requestBody;
                try {
                    insert log;
                }  
                catch (Exception innerEx) {
                    System.debug('Callout Error: ' + innerEx.getMessage());
                    System.debug('Callout Error: ' + innerEx.getLineNumber());
                    
                }
            }    
        }
    }
    public static void updateContactDetailsOnInsight(string rowVersion, Integer parentId, String contactId){
        if(String.isBlank(rowVersion) || String.isBlank(String.ValueOf(parentId)) || String.isBlank(contactId)){
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Contact__c = contactId;
            log.mm_Error_Description__c = 'rowVersion->'+rowVersion+'\n contactId->'+contactId+'\n parentId->'+parentId;
            try {
                insert log;
            }  
            catch (Exception innerEx) {
                System.debug('Callout Error: ' + innerEx.getMessage());
                System.debug('Callout Error: ' + innerEx.getLineNumber());
                
            }
            return;
        }
        Contact con = [SELECT Id, Addressee__c ,Birthdate ,Email ,Fax ,mm_Created_When__c ,mm_Created_Who__c ,mm_External_Id__c ,mm_Is_Primary_Contact__c ,MobilePhone ,Name ,OtherPhone ,Phone ,Salutation ,Title,Account.mm_INSIGHTS_Id__c, RowVersion__c from Contact where Id = :contactId  LIMIT 1];
        
        InsightAPIHelperContact.sendContactDetails(con,'update',rowVersion, parentId);    
    }
    
}