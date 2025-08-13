/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyFromInsightTest
* Description: Common method called from queuable to get the Policy from Insight which are created or updated 
* Referenced From : FetchUpdatedPolicyFromInsightQueueable,FetchCreatedPolicyFromInsightQueueable
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
	Aakash Jain 	8-July-2025		Added null check for record.PolicyNumber in created and updated method also Added integration logs fields for detailed errors
*/


public class FetchPolicyFromInsight {
    public static void getCreatedPolicyDatafromInsight(){
        //custom setting
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        String endpointPath = '/Policy/List';
        String httpMethod = 'POST'; 
        Set<String> clientIdsSet = new Set<string>();
        List<Account> accountList = new List<Account>();
        Set<String> policyInsightIdSet = new Set<string>();
        List<InsurancePolicy> IPListToUpsert = new List<InsurancePolicy>();
        List<InsurancePolicy> existingInsurancePolicy = new List<InsurancePolicy>();
        List<mm_Integration_Log__c> errorLogs = new List<mm_Integration_Log__c>();
        Map<String, String> clientIdByAccountIdMap = new Map<String, String>();
        Map<String, String> insightPolicyIdByInsurancePolicyIdMap = new Map<String, String>();
        Set<String> policyInsurerIdSet  = new Set<String>();
        List<Account> insuredAccntList = new List<Account>();
        Map<String,String> insuredIdByAccntIdMap = new Map<string,string>();
        
        
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndpoint(insightAPI[0].Insight_Endpoint__c + endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        req.setBody(PolicyJsonBuilder.generateCreatedPolicyJson());
        
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response: ' + res.getBody());
            String jsonResponse = res.getBody();
            if(res.getStatusCode() == 200){
                PolicyWrapper wrapper = (PolicyWrapper)JSON.deserialize(jsonResponse, PolicyWrapper.class);
                system.debug('wrapper->'+wrapper);
                
                for (PolicyWrapper.PolicyRecord record : wrapper.Results) {
                    clientIdsSet.add(string.valueOf(record.ClientId));
                    policyInsightIdSet.add(string.valueOf(record.Id));
                    policyInsurerIdSet.add(string.valueOf(record.InsurerId));
                }
                system.debug('clientIdsSet->'+clientIdsSet);
                system.debug('policyInsightIdSet->'+policyInsightIdSet);
                system.debug('policyInsurerIdSet->'+policyInsurerIdSet);
                
                if(!policyInsightIdSet.isEmpty()){
                    existingInsurancePolicy = [Select Id,mm_External_Id__c From InsurancePolicy where mm_External_Id__c IN : policyInsightIdSet];
                    system.debug('existingInsurancePolicy->'+existingInsurancePolicy);
                    if(!existingInsurancePolicy.isEmpty()){
                        for(InsurancePolicy poliyRec : existingInsurancePolicy){
                            insightPolicyIdByInsurancePolicyIdMap.put(poliyRec.mm_External_Id__c, poliyRec.Id);
                        }
                    }
                }
                if(!policyInsurerIdSet.isEmpty()){
                    system.debug('PolicyInsuredIdSet->'+policyInsurerIdSet);
                    insuredAccntList = [Select Id, mm_INSIGHTS_Id__c From Account where mm_INSIGHTS_Id__c in : policyInsurerIdSet];
                    system.debug('insuredAccountList->'+insuredAccntList);
                    if(!insuredAccntList.isEmpty()){
                        for(Account acc : insuredAccntList){ 
                            insuredIdByAccntIdMap.put(acc.mm_INSIGHTS_Id__c,acc.Id);
                            system.debug('acc.mm_INSIGHTS_Id__c->'+acc.mm_INSIGHTS_Id__c);
                            system.debug('acc.Id->'+acc.Id);           
                        }       
                    }
                }
                
                system.debug('insightPolicyIdByInsurancePolicyIdMap->'+insightPolicyIdByInsurancePolicyIdMap);
                
                if(!clientIdsSet.isEmpty()){
                    accountList = [Select Id, mm_INSIGHTS_Id__c From Account where mm_INSIGHTS_Id__c in : clientIdsSet];
                    system.debug('accountList->'+accountList);
                    
                    if(!accountList.isEmpty()){
                        for(Account acc : accountList){
                            clientIdByAccountIdMap.put(acc.mm_INSIGHTS_Id__c, acc.Id);
                            system.debug('acc.mm_INSIGHTS_Id__c->'+acc.mm_INSIGHTS_Id__c);
                            system.debug('acc.Id->'+acc.Id);
                        }
                        if(!clientIdByAccountIdMap.isEmpty()){
                            for (PolicyWrapper.PolicyRecord record : wrapper.Results) {
                                if(clientIdByAccountIdMap.ContainsKey(String.ValueOf(record.ClientId)) && String.isNotBlank(record.PolicyNumber)){
                                    InsurancePolicy IPrecToInsert = new InsurancePolicy();
                                    if(record.PolicyNumber !=null) IPrecToInsert.Name = record.PolicyNumber;
                                    IPrecToInsert.NameInsuredId = clientIdByAccountIdMap.get(String.ValueOf(record.ClientId));
                                    if(record.Balance !=null) IPrecToInsert.mm_Balance_Due__c = record.Balance;
                                    if(record.Description !=null) IPrecToInsert.PolicyDescription = record.Description;
                                    if(record.TypeDescription !=null) IPrecToInsert.mm_Type_Description__c = record.TypeDescription;
                                    IPrecToInsert.EffectiveDate = record.EffectiveDate;
                                    IPrecToInsert.EffectiveFromDate = record.FromDate;
                                    IPrecToInsert.EffectiveToDate = record.ToDate;
                                    if(record.Insured !=null) IPrecToInsert.mm_Insured_Name_for_Policy__c = record.Insured;
                                    if(record.NumTransactions !=null) IPrecToInsert.mm_Number_of_Transactions__c = record.NumTransactions;
                                    IPrecToInsert.mm_Is_Instalment_Policy__c = record.IsInstalmentPolicy;
                                    if(record.Period !=null) IPrecToInsert.mm_Period__c = record.Period;
                                    IPrecToInsert.mm_Has_Coinsurance__c = record.HasCoinsurance;
                                    IPrecToInsert.mm_Has_Multipleclient__c = record.HasMultiClient;
                                    if(record.StandardIndustryCode !=null) IPrecToInsert.mm_Standard_Industry_Code__c = record.StandardIndustryCode;                                    
                                    IPrecToInsert.ReferencePolicyNumber = record.PolicyNumber;
                                    if(record.PolicyNumber !=null) IPrecToInsert.ReferencePolicyNumber = record.PolicyNumber;
                                    if(record.PolicyNumber !=null) IPrecToInsert.mm_CBN_Policy_Number__c = record.PolicyNumber;                                   
                                    if(record.ClassOfRisk != null && record.ClassOfRiskId != null && record.InsurerId != null)
                                        IPrecToInsert.ProductId = getClassofRiskIdSF(record.ClassOfRisk, record.ClassOfRiskId, record.InsurerId);
                                    if(record.PolicyTeamId != null && getPolicyTeamIdSF(record.PolicyTeamId) != null){
                                        IPrecToInsert.PolicyTeamId__c = getPolicyTeamIdSF(record.PolicyTeamId);                                       
                                    }
                                    if(record.InsurerId != null && insuredIdByAccntIdMap.containsKey(String.ValueOf(record.InsurerId))){    
                                        IPrecToInsert.mm_Insurer__c = insuredIdByAccntIdMap.get(String.ValueOf(record.InsurerId));
                                    }
                                    if(record.ToDate != null){    
                                        IPrecToInsert.ExpirationDate = DateTime.newInstance(record.ToDate, Time.newInstance(0, 0, 0, 0));
                                    }
                                    
                                    system.debug('insightPolicyIdByInsurancePolicyIdMap.containsKey(string.valueOf(record.Id))->'+insightPolicyIdByInsurancePolicyIdMap.containsKey(string.valueOf(record.Id)));
                                    if(insightPolicyIdByInsurancePolicyIdMap.containsKey(string.valueOf(record.Id))){
                                        system.debug('insightPolicyIdByInsurancePolicyIdMap.get(string.valueOf(record.Id))->'+insightPolicyIdByInsurancePolicyIdMap.get(string.valueOf(record.Id)));
                                        IPrecToInsert.Id = insightPolicyIdByInsurancePolicyIdMap.get(string.valueOf(record.Id));
                                    }else{
                                        system.debug('String.ValueOf(record.Id)->'+String.ValueOf(record.Id));
                                        IPrecToInsert.mm_External_Id__c = String.ValueOf(record.Id);
                                    }
                                    IPListToUpsert.add(IPrecToInsert);
                                    system.debug('IPrecToInsert->'+IPrecToInsert);
                                }
                            }
                        }
                    }
                }
            }else{
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+PolicyJsonBuilder.generateCreatedPolicyJson();
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getCreatedPolicyDatafromInsight';
                insert log;
            }
            if(!IPListToUpsert.isEmpty()){
                try{
                    Database.UpsertResult[] results  =  Database.upsert(IPListToUpsert, false);
                    system.debug('IPListToUpsert'+IPListToUpsert);
                    
                    for (Integer i = 0; i < results.size(); i++) {
                        Database.UpsertResult result = results[i];
                        
                        if (!result.isSuccess()) {
                            for (Database.Error err : result.getErrors()) {
                                mm_Integration_Log__c log = new mm_Integration_Log__c();
                                if(IPListToUpsert[i].Id != null)
                                    log.Insurance_Policy__c = IPListToUpsert[i].Id;
                                log.Status_Code__c   = string.valueOf(err.getStatusCode());
                                log.mm_Error_Description__c = jsonResponse;
                                log.Request_Endpoint__c = endpointPath;
                                log.mm_Payload__c =  'requestBody->'+PolicyJsonBuilder.generateCreatedPolicyJson();                               
                                log.mm_Log_Time__c = system.now();
                                log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getCreatedPolicyDatafromInsight';
                                log.mm_Message__c = '171 ErrorStatusCode  ->'+err.getStatusCode()+'\n\n ErrorMessage  ->'+err.getMessage()+'\n\n Error Fields ->'+err.getFields();
                                errorLogs.add(log);
                            }
                        }
                    }
                    insert errorLogs;
                }catch (Exception ex) {
                    System.debug('Callout Error: ' + ex.getMessage());
                    mm_Integration_Log__c log = new mm_Integration_Log__c();
                    log.mm_Error_Description__c = jsonResponse;
                    log.Request_Endpoint__c = endpointPath;
                    log.mm_Payload__c =  'requestBody->'+PolicyJsonBuilder.generateCreatedPolicyJson();
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getCreatedPolicyDatafromInsight';
                    log.mm_Message__c = '186 ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                    insert log;
                }                
            }
        }catch (Exception ex) {
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody->'+PolicyJsonBuilder.generateCreatedPolicyJson();
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getCreatedPolicyDatafromInsight';
            log.mm_Message__c = '196 ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
            System.debug('Callout Error: ' + ex.getMessage());
        }
    }
    public static void getUpdatedPolicyDatafromInsight(){
        //custom setting
        List<Insight_API_Details__c> insightAPI = Insight_API_Details__c.getall().values();
        String endpointPath = '/Policy/List';
        String httpMethod = 'POST'; 
        Set<String> clientIdsSet = new Set<string>();
        List<Account> accountList = new List<Account>();
        Set<String> policyInsightIdSet = new Set<string>();
        List<InsurancePolicy> IPListToUpsert = new List<InsurancePolicy>();
        List<InsurancePolicy> existingInsurancePolicy = new List<InsurancePolicy>();
        List<mm_Integration_Log__c> errorLogs = new List<mm_Integration_Log__c>();
        Map<String, String> clientIdByAccountIdMap = new Map<String, String>();
        Map<String, String> insightPolicyIdByInsurancePolicyIdMap = new Map<String, String>();
        Set<String> policyInsurerIdSet  = new Set<String>();
        List<Account> insuredAccntList = new List<Account>();
        Map<String,String> insuredIdByAccntIdMap = new Map<string,string>();
        
        HttpRequest req = new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(60000);
        req.setBody(PolicyJsonBuilder.generateUpdatedPolicyJson());
        String jsonResponse = '';
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response: ' + res.getBody());
             jsonResponse = res.getBody(); 
            if(res.getStatusCode() == 200){
                PolicyWrapper wrapper = (PolicyWrapper)JSON.deserialize(jsonResponse, PolicyWrapper.class);
                system.debug('wrapper->'+wrapper);
                
                for (PolicyWrapper.PolicyRecord record : wrapper.Results) {
                    clientIdsSet.add(string.valueOf(record.ClientId));
                    policyInsightIdSet.add(string.valueOf(record.Id));
                    policyInsurerIdSet.add(string.valueOf(record.InsurerId));
                }
                system.debug('clientIdsSet->'+clientIdsSet);
                system.debug('policyInsightIdSet->'+policyInsightIdSet);
                
                if(!policyInsightIdSet.isEmpty()){
                    existingInsurancePolicy = [Select Id,mm_External_Id__c From InsurancePolicy where mm_External_Id__c IN : policyInsightIdSet];
                    system.debug('existingInsurancePolicy->'+existingInsurancePolicy);
                    if(!existingInsurancePolicy.isEmpty()){
                        for(InsurancePolicy poliyRec : existingInsurancePolicy){
                            insightPolicyIdByInsurancePolicyIdMap.put(poliyRec.mm_External_Id__c, poliyRec.Id);
                        }
                    }
                }
                system.debug('insightPolicyIdByInsurancePolicyIdMap->'+insightPolicyIdByInsurancePolicyIdMap);
                if(!policyInsurerIdSet.isEmpty()){
                    insuredAccntList = [Select Id, mm_INSIGHTS_Id__c From Account where mm_INSIGHTS_Id__c in : policyInsurerIdSet];
                    system.debug('insuredAccountList->'+insuredAccntList);
                    if(!insuredAccntList.isEmpty()){
                        for(Account acc : insuredAccntList){ 
                            insuredIdByAccntIdMap.put(acc.mm_INSIGHTS_Id__c,acc.Id);
                            system.debug('acc.mm_INSIGHTS_Id__c->'+acc.mm_INSIGHTS_Id__c);
                            system.debug('acc.Id->'+acc.Id);           
                        }       
                    }
                }
                if(!clientIdsSet.isEmpty()){
                    accountList = [Select Id, mm_INSIGHTS_Id__c From Account where mm_INSIGHTS_Id__c in : clientIdsSet];
                    system.debug('accountList->'+accountList);
                    if(!accountList.isEmpty()){
                        for(Account acc : accountList){
                            clientIdByAccountIdMap.put(acc.mm_INSIGHTS_Id__c, acc.Id);
                            system.debug('acc.mm_INSIGHTS_Id__c->'+acc.mm_INSIGHTS_Id__c);
                            system.debug('acc.Id->'+acc.Id);
                        }
                        
                        if(!clientIdByAccountIdMap.isEmpty()){
                            for (PolicyWrapper.PolicyRecord record : wrapper.Results) {
                                if(clientIdByAccountIdMap.ContainsKey(String.ValueOf(record.ClientId)) && String.isNotBlank(record.PolicyNumber)){
                                    InsurancePolicy IPrecToInsert = new InsurancePolicy();
                                    if(record.PolicyNumber !=null) IPrecToInsert.Name = record.PolicyNumber;
                                    IPrecToInsert.NameInsuredId = clientIdByAccountIdMap.get(String.ValueOf(record.ClientId));
                                    if(record.Balance !=null) IPrecToInsert.mm_Balance_Due__c = record.Balance;
                                    if(record.Description !=null) IPrecToInsert.PolicyDescription = record.Description;
                                    if(record.TypeDescription !=null) IPrecToInsert.mm_Type_Description__c = record.TypeDescription;
                                    IPrecToInsert.EffectiveDate = record.EffectiveDate;
                                    IPrecToInsert.EffectiveFromDate = record.FromDate;
                                    IPrecToInsert.EffectiveToDate = record.ToDate;
                                    if(record.Insured !=null) IPrecToInsert.mm_Insured_Name_for_Policy__c = record.Insured;
                                    if(record.NumTransactions !=null) IPrecToInsert.mm_Number_of_Transactions__c = record.NumTransactions;
                                    IPrecToInsert.mm_Is_Instalment_Policy__c = record.IsInstalmentPolicy;
                                    if(record.Period !=null) IPrecToInsert.mm_Period__c = record.Period;
                                    IPrecToInsert.mm_Has_Coinsurance__c = record.HasCoinsurance;
                                    IPrecToInsert.mm_Has_Multipleclient__c = record.HasMultiClient;
                                    if(record.StandardIndustryCode !=null) IPrecToInsert.mm_Standard_Industry_Code__c = record.StandardIndustryCode;
                                    if(record.PolicyNumber !=null) IPrecToInsert.ReferencePolicyNumber = record.PolicyNumber;
                                    if(record.PolicyNumber !=null) IPrecToInsert.mm_CBN_Policy_Number__c = record.PolicyNumber;
                                    if(record.ClassOfRisk != null && record.ClassOfRiskId != null && record.InsurerId != null)
                                        IPrecToInsert.ProductId = getClassofRiskIdSF(record.ClassOfRisk, record.ClassOfRiskId, record.InsurerId);
                                    if(record.PolicyTeamId != null && getPolicyTeamIdSF(record.PolicyTeamId) != null){
                                        IPrecToInsert.PolicyTeamId__c = getPolicyTeamIdSF(record.PolicyTeamId);                                       
                                    }
                                    if(record.InsurerId != null && insuredIdByAccntIdMap.containsKey(String.ValueOf(record.InsurerId))){    
                                        IPrecToInsert.mm_Insurer__c = insuredIdByAccntIdMap.get(String.ValueOf(record.InsurerId));
                                    }
                                    if(record.ToDate != null){    
                                        IPrecToInsert.ExpirationDate = DateTime.newInstance(record.ToDate, Time.newInstance(0, 0, 0, 0));
                                    }
                                    //if exists assign id else assign mm_External_Id__c
                                    system.debug('insightPolicyIdByInsurancePolicyIdMap.containsKey(string.valueOf(record.Id))->'+insightPolicyIdByInsurancePolicyIdMap.containsKey(string.valueOf(record.Id)));
                                    if(insightPolicyIdByInsurancePolicyIdMap.containsKey(string.valueOf(record.Id))){
                                        system.debug('insightPolicyIdByInsurancePolicyIdMap.get(string.valueOf(record.Id))->'+insightPolicyIdByInsurancePolicyIdMap.get(string.valueOf(record.Id)));
                                        IPrecToInsert.Id = insightPolicyIdByInsurancePolicyIdMap.get(string.valueOf(record.Id));
                                    }else{
                                        system.debug('String.ValueOf(record.Id)->'+String.ValueOf(record.Id));
                                        IPrecToInsert.mm_External_Id__c = String.ValueOf(record.Id);
                                    }
                                    IPListToUpsert.add(IPrecToInsert);
                                    system.debug('IPrecToInsert->'+IPrecToInsert);
                                }
                            }
                        }
                    }
                }
            }else{
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+PolicyJsonBuilder.generateUpdatedPolicyJson();
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getUpdatedPolicyDatafromInsight';
                log.mm_Message__c = '330 ErrorStatusCode  ->'+res.getBody();                          
                insert log;
            }
            if(!IPListToUpsert.isEmpty()){
                try{
                    Database.UpsertResult[] results  =  Database.upsert(IPListToUpsert, false);
                    system.debug('IPListToUpsert'+IPListToUpsert);
                    for (Integer i = 0; i < results.size(); i++) {
                        Database.UpsertResult result = results[i];
                        if (!result.isSuccess()) {
                            for (Database.Error err : result.getErrors()) {
                                mm_Integration_Log__c log = new mm_Integration_Log__c();
                                if(IPListToUpsert[i].Id != null)
                                    log.Insurance_Policy__c     = IPListToUpsert[i].Id;
                                log.Status_Code__c   = string.valueOf(err.getStatusCode());
                                log.mm_Error_Description__c = jsonResponse;
                                log.Request_Endpoint__c = endpointPath;
                                log.mm_Payload__c =  'requestBody->'+PolicyJsonBuilder.generateUpdatedPolicyJson();
                                log.mm_Log_Time__c = system.now();
                                log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getUpdatedPolicyDatafromInsight';
                                log.mm_Message__c = ' 351 ErrorStatusCode  ->'+err.getStatusCode()+'\n\n ErrorMessage  ->'+err.getMessage()+'\n\n Error Fields ->'+err.getFields();                          
                                errorLogs.add(log);
                            }
                        }
                    }
                    insert errorLogs;
                }catch (Exception ex) {
                    System.debug('Callout Error: ' + ex.getMessage());
                    mm_Integration_Log__c log = new mm_Integration_Log__c();
                    log.mm_Error_Description__c = jsonResponse;
                    log.Request_Endpoint__c = endpointPath;
                    log.mm_Payload__c =  'requestBody->'+PolicyJsonBuilder.generateUpdatedPolicyJson();
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getUpdatedPolicyDatafromInsight';
                    log.mm_Message__c = '365 ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                    insert log;
                }                
            }
        }catch (Exception ex) {
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.mm_Error_Description__c = jsonResponse;
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody<->'+PolicyJsonBuilder.generateUpdatedPolicyJson();
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'FetchPolicyFromInsight <-> getUpdatedPolicyDatafromInsight';
            log.mm_Message__c = '376 ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
            System.debug('Callout Error: ' + ex.getMessage());
        }
    }
    
    public static string getClassofRiskIdSF(string classOfRiskName, Integer classOfRiskId, Integer insurerId){
        system.debug('getClassofRiskIdSF->   '+' classOfRiskName ->'+classOfRiskName+'classOfRiskId->'+classOfRiskId+'insurerId->'+insurerId );
        if(string.isBlank(classOfRiskName) || string.isBlank(String.valueOf(classOfRiskId)) || string.isBlank(String.valueOf(insurerId))){
            return null;
        }
        // Insurer_Id__c Class_of_Risk_Id__c
        List<Product2> productList = [Select id From Product2 where Class_of_Risk_Id__c =: classOfRiskId AND Name =: classOfRiskName order by LastModifiedDate Desc limit 1];
        system.debug('productList->'+productList);
        
        if(!productList.isEmpty()){
            return productList[0].Id;
        }else{
            Product2 productToInsert = new Product2();
            productToInsert.Name = classOfRiskName;
            productToInsert.Class_of_Risk_Id__c = classOfRiskId;
            productToInsert.Insurer_Id__c = insurerId;
            insert productToInsert;
            system.debug('productToInsert->'+productToInsert);
            
            return productToInsert.Id;
        }
    }
    public static string getPolicyTeamIdSF(Integer policyTeamId){
        system.debug('getPolicyTeamIdSF->   '+' policyTeamId ->'+policyTeamId );
        if(string.isBlank(String.valueOf(policyTeamId))){
            return null;
        }
        List<User> userList = [Select PolicyTeamId__c,ID From User where PolicyTeamId__c =: policyTeamId limit 1];
        system.debug('userList->'+userList);
        
        if(!userList.isEmpty()){
            return userList[0].Id;
        }else{
            return null;
        }
    }
}