/*****
* Created by Saurabh Chandra[10-06-2025]
* Test Class: FetchPolicyTransPrtcpntSchTest
* Description: API callout to get Participant from Insight
* Referenced From : FetchPolicyTransPrtpntInsightQue
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
*	Aakash Jain		08-July-2025	Added settimeout and added error log fields
*/ 

public class FetchPolicyTransCoParticipantFromInsight {
    // polId = Policy transactionId
    public static void getPolicyTransactionParticipantDatafromInsight(integer polId){
        //custom setting
        List<insurex__c> insurexCS = insurex__c.getall().values();
        String endpointPath = '/MultiClient/List';
        String httpMethod = 'POST'; 
        Set<String> AccountInsightSet = new Set<String>();
        Set<String> policyTransInsightSet = new Set<String>();
        Set<String> policyTrancationParticipantInsightSet = new Set<String>();
        List<Account> existingAccountList = new List<Account>();
        List<mm_Integration_Log__c> errorLogs = new List<mm_Integration_Log__c>();
        List<InsurancePolicyTransaction> existingPolicyTransList = new List<InsurancePolicyTransaction>();
        List<InsurancePolicyParticipant> existingPolicyParticipantList = new List<InsurancePolicyParticipant>();
        List<InsurancePolicyParticipant> PolicyParticipantListToUpsert = new List<InsurancePolicyParticipant>();
        Map<String, String> accountInsightIdByAccountIdMap = new Map<String, String>();
        Map<String, String> policyTranInsightIdByPolicyTranIdMap = new Map<String, String>();
        Map<String, String> policyTranPartInsightIdByPolicyTransPartIdMap = new Map<String, String>();
        Map<String, String> policyTranIdByPolicyIdMap = new Map<String, String>();
        
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndpoint(insurexCS[0].endpoint__c + endpointPath);
        req.setHeader('INSIGHT-USERNAME', insurexCS[0].insightUsername__c);
        req.setHeader('INSIGHT-PASSWORD', insurexCS[0].insightPassword__c);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        req.setBody(PolicyTransCoParticipantJsonBuilder.buildRequestBody(polId));
        
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response: ' + res.getBody());
            String jsonResponse = res.getBody();
            if(res.getStatusCode() == 200){
                
                PolicyTransactionParticipantWrapper parsedData = (PolicyTransactionParticipantWrapper)JSON.deserialize(jsonResponse, PolicyTransactionParticipantWrapper.class);
                //ParentId = policytranscation
                //client -  accountid
                
                for (PolicyTransactionParticipantWrapper.ClientWrapper client : parsedData.Clients) {
                    System.debug('Account Insight Id: ' + client.ClientId);
                    System.debug('Account Name: ' + client.ClientName);
                    System.debug('Insurance Policay Transactopn Insight Id: ' + client.ParentId);
                    System.debug('Policy transaction Participant Insight Id : ' + client.Id);
                    policyTrancationParticipantInsightSet.add(String.valueOf(client.Id));
                    AccountInsightSet.add(client.ClientId);
                    policyTransInsightSet.add(client.ParentId);
                }
                
                System.debug('policyTrancationParticipantInsightSet' + policyTrancationParticipantInsightSet);
                System.debug('AccountInsightSet ' + AccountInsightSet);
                System.debug('policyTransInsightSet' + policyTransInsightSet);
                
                if(!policyTrancationParticipantInsightSet.isEmpty()){
                    existingPolicyParticipantList = [SELECT Id,IPP_Insight_Id__c FROM InsurancePolicyParticipant WHERE IPP_Insight_Id__c  IN: policyTrancationParticipantInsightSet];
                    if(!existingPolicyParticipantList.isEmpty()){
                        for(InsurancePolicyParticipant insurancePolicyPartRec : existingPolicyParticipantList){
                            policyTranPartInsightIdByPolicyTransPartIdMap.put(insurancePolicyPartRec.IPP_Insight_Id__c, insurancePolicyPartRec.Id);
                        }
                    }
                } 
                System.debug('policyTranPartInsightIdByPolicyTransPartIdMap ' + policyTranPartInsightIdByPolicyTransPartIdMap);
                if(!AccountInsightSet.isEmpty()){
                    existingAccountList = [Select Id, mm_INSIGHTS_Id__c From Account where mm_INSIGHTS_Id__c in : AccountInsightSet];
                    if(!existingAccountList.isEmpty()){
                        for(Account accRec : existingAccountList){
                            accountInsightIdByAccountIdMap.put(accRec.mm_INSIGHTS_Id__c, accRec.Id);
                        }
                    }
                }
                System.debug('accountInsightIdByAccountIdMap ' + accountInsightIdByAccountIdMap);
                if(!policyTransInsightSet.isEmpty()){
                    existingPolicyTransList = [Select Id,mm_Insight_Record_ID__c,InsurancePolicy.mm_External_Id__c,InsurancePolicyId From InsurancePolicyTransaction where mm_Insight_Record_ID__c IN : policyTransInsightSet];
                    System.debug('existingPolicyTransList ' + existingPolicyTransList);
                    if(!existingPolicyTransList.isEmpty()){
                        for(InsurancePolicyTransaction insurancePolicyTranRec : existingPolicyTransList){
                            policyTranInsightIdByPolicyTranIdMap.put(insurancePolicyTranRec.mm_Insight_Record_ID__c, insurancePolicyTranRec.Id);
                            policyTranIdByPolicyIdMap.put(insurancePolicyTranRec.Id, insurancePolicyTranRec.InsurancePolicyId);
                        }
                        System.debug('policyTranInsightIdByPolicyTranIdMap ' + policyTranInsightIdByPolicyTranIdMap);                                     
                        if(!policyTranInsightIdByPolicyTranIdMap.isEmpty()){
                            for (PolicyTransactionParticipantWrapper.ClientWrapper client : parsedData.Clients) {
                                system.debug('policyTranInsightIdByPolicyTranIdMap.containsKey(client.ParentId)->'+policyTranInsightIdByPolicyTranIdMap.containsKey(client.ParentId));
                                if(policyTranInsightIdByPolicyTranIdMap.containsKey(client.ParentId)){
                                    InsurancePolicyParticipant policyParticpant = new InsurancePolicyParticipant();
                                    policyParticpant.InsurancePolicyId =  policyTranIdByPolicyIdMap.get(policyTranInsightIdByPolicyTranIdMap.get(client.ParentId));
                                    policyParticpant.Role = 'Other';
                                    if(accountInsightIdByAccountIdMap.containsKey(client.ClientId))
                                        policyParticpant.PrimaryParticipantAccountId = accountInsightIdByAccountIdMap.get(client.ClientId);
                                    policyParticpant.ParticipantName = client.ClientName;
                                    //if exists assign id else assign IPP_Insight_Id__c
                                    system.debug('policyTranInsightIdByPolicyTranIdMap.containsKey(string.valueOf(client.Id))->'+policyTranInsightIdByPolicyTranIdMap.containsKey(string.valueOf(client.Id)));
                                    if(policyTranPartInsightIdByPolicyTransPartIdMap.containsKey(string.valueOf(client.Id))){
                                        system.debug('insightPolicyIdByInsurancePolicyIdMap.get(string.valueOf(client.Id))->'+policyTranPartInsightIdByPolicyTransPartIdMap.get(string.valueOf(client.Id)));
                                        policyParticpant.Id = policyTranPartInsightIdByPolicyTransPartIdMap.get(string.valueOf(client.Id));
                                    }else{
                                        system.debug('string.valueOf(client.Id)->'+string.valueOf(client.Id));
                                        policyParticpant.IPP_Insight_Id__c = String.ValueOf(client.Id);
                                    }
                                    system.debug('policyParticpant->'+policyParticpant);
                                    PolicyParticipantListToUpsert.add(policyParticpant);
                                }
                            }
                        }
                    }
                }
                system.debug('PolicyParticipantListToUpsert->'+PolicyParticipantListToUpsert);
            }else{
                // Handle API error responses
                
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+PolicyTransCoParticipantJsonBuilder.buildRequestBody(polId);
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'FetchPolicyTransCoParticipantFromInsight <-> getPolicyTransactionParticipantDatafromInsight';
                insert log;
            }
            if(!PolicyParticipantListToUpsert.isEmpty()){
                    Database.UpsertResult[] results  =  Database.upsert(PolicyParticipantListToUpsert, false);
                    system.debug('PolicyParticipantListToUpsert'+PolicyParticipantListToUpsert);
                    for (Integer i = 0; i < results.size(); i++) {
                        Database.UpsertResult result = results[i];
                        if (!result.isSuccess()) {
                            for (Database.Error err : result.getErrors()) {
                                mm_Integration_Log__c log = new mm_Integration_Log__c();
                                if(PolicyParticipantListToUpsert[i].Id != null)
                                    log.Insurance_Policy_Participant__c     = PolicyParticipantListToUpsert[i].Id;
                                log.Status_Code__c   = string.valueOf(err.getStatusCode());
                                log.mm_Error_Description__c = jsonResponse;
                                log.Request_Endpoint__c = endpointPath;
                                log.mm_Payload__c =  'requestBody->'+PolicyTransCoParticipantJsonBuilder.buildRequestBody(polId);                               
                                log.mm_Log_Time__c = system.now();
                                log.mm_Failing_Component__c = 'FetchPolicyTransCoParticipantFromInsight <-> getPolicyTransactionParticipantDatafromInsight';
                                log.mm_Message__c = 'ErrorStatusCode  ->'+err.getStatusCode()+'\n\n ErrorMessage  ->'+err.getMessage()+'\n\n Error Fields ->'+err.getFields();
                                errorLogs.add(log);
                            }
                        }
                    }
                    insert errorLogs;
               
            }
        }catch (Exception ex) {
            System.debug('Callout Error: ' + ex.getMessage());
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody->'+PolicyTransCoParticipantJsonBuilder.buildRequestBody(polId);
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'FetchPolicyTransCoParticipantFromInsight <-> getPolicyTransactionParticipantDatafromInsight';
            log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
        }
    }
}