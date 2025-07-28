/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyTransFromInsightTest
* Description: Common method called from queuable to get the Policy Transaction from Insight which are created or updated 
* Referenced From : FetchCrtdPolicyTransFromInsightQueu,FetchUpdatedPolicyTranFromInsightQue
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
*	Aakash Jain		08-July-2025	Formatted DateTime for Postedwhen field
*	Aakash Jain		08-July-2025	Removed error log insertion if no parent policy is found by external id, added settimeout and added error log fields
*/

public class FetchPolicyTransactionFromInsight {
    
    public static void getCreatedPolicyTransactionDatafromInsight(){
        List<Insight_API_Details__c> insightAPI=Insight_API_Details__c.getAll().values();
        String endpointPath = '/PolicyTransaction/List';
        String httpMethod = 'POST'; 
        List<InsurancePolicy> IPListToInsert = new List<InsurancePolicy>();
        Set<String> policyInsightIdSet = new Set<String>();
        Set<String> policyTransactionInsightIdSet = new Set<String>();
        List<InsurancePolicy> existingInsurancePolicy = new List<InsurancePolicy>();
        List<InsurancePolicyTransaction> existingPolicyTransactionList = new List<InsurancePolicyTransaction>();
        List<InsurancePolicyTransaction> PolicyTransactionListToUpsert = new List<InsurancePolicyTransaction>();
        List<mm_Integration_Log__c> errorLogs = new List<mm_Integration_Log__c>();
        Map<String, String> transactionIdByPolicyIdMap = new Map<String, String>();
        Map<String, String> policyTransExternalIdByPolicyTransId = new Map<String, String>();
        Map<String, String> policyExternalIdByPolicyId = new Map<String, String>();
        
        HttpRequest req=new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(PolicyTransactionJsonBuilder.generateCreatedPolicyTransactionJson());
        req.setTimeout(60000);
        
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            String jsonResponse=res.getBody();
            system.debug('res->'+res);
            if(res.getStatusCode()==200){
                system.debug('jsonResponse->'+jsonResponse);
                
                PolicyTransactionWrapper wrapper=(PolicyTransactionWrapper)JSON.deserialize(jsonResponse,PolicyTransactionWrapper.class);
                system.debug('wrapper->'+wrapper);
                
                for(PolicyTransactionWrapper.PolicyTransactionRecord record : wrapper.Results){
                    policyInsightIdSet.add(String.valueOf(record.PolicyId));
                    policyTransactionInsightIdSet.add(string.valueOf(record.Id));
                }
                System.debug('policyInsightIdSet: '+policyInsightIdSet);
                System.debug('policyTransactionInsightIdSet: '+policyTransactionInsightIdSet);
                
                if(!policyTransactionInsightIdSet.isEmpty()){
                    existingPolicyTransactionList = [SELECT Id,mm_Insight_Record_ID__c FROM InsurancePolicyTransaction WHERE mm_Insight_Record_ID__c  IN: policyTransactionInsightIdSet];
                    system.debug('existingPolicyTransactionList'+existingPolicyTransactionList);
                    
                    if(!existingPolicyTransactionList.isEmpty()){
                        for(InsurancePolicyTransaction policyTransactionRec : existingPolicyTransactionList){
                            policyTransExternalIdByPolicyTransId.put(String.valueOf(policyTransactionRec.mm_Insight_Record_ID__c), policyTransactionRec.Id);
                        }
                    }
                }
                system.debug('policyTransExternalIdByPolicyTransId'+policyTransExternalIdByPolicyTransId);
                
                if(!policyInsightIdSet.isEmpty()){
                    existingInsurancePolicy = [Select Id,mm_External_Id__c From InsurancePolicy where mm_External_Id__c IN : policyInsightIdSet];
                    system.debug('existingInsurancePolicy'+existingInsurancePolicy);
                    if(!existingInsurancePolicy.isEmpty()){
                        for(InsurancePolicy poloicyRec : existingInsurancePolicy){
                            policyExternalIdByPolicyId.put(String.valueOf(poloicyRec.mm_External_Id__c), poloicyRec.Id);
                        }               
                        system.debug('policyExternalIdByPolicyId'+policyExternalIdByPolicyId);
                        if(!policyExternalIdByPolicyId.isEmpty()){
                            for (PolicyTransactionWrapper.PolicyTransactionRecord record : wrapper.Results) {
                                system.debug('policyExternalIdByPolicyId.ContainsKey(String.ValueOf(record.policyId))->'+policyExternalIdByPolicyId.ContainsKey(String.ValueOf(record.policyId)));
                                system.debug('-----'+String.ValueOf(record.policyId));
                                if(policyExternalIdByPolicyId.ContainsKey(String.ValueOf(record.policyId))){
                                    InsurancePolicyTransaction iptRecord = new InsurancePolicyTransaction();
                                    if (record.accountId != null) iptRecord.Client_ID__c = record.accountId;
                                    if (record.EffectiveDate != null) iptRecord.mm_Effective_Date__c = record.EffectiveDate;
                                    if (record.InvoiceNumber != null) iptRecord.Invoice_Number__c = record.InvoiceNumber;
                                    if (record.ARCommission != null) iptRecord.mm_AR_Comm__c = record.ARCommission;
                                    if (record.ARCommissionGST != null) iptRecord.mm_AR_Comm_GST__c = record.ARCommissionGST;
                                    if (record.ARFee != null) iptRecord.mm_AR_Fee__c = record.ARFee;
                                    if (record.ARFeeGST != null) iptRecord.mm_AR_Fee_GST__c = record.ARFeeGST;
                                    if (record.ARTotalPayable != null) iptRecord.mm_AR_Total_Payable__c = record.ARTotalPayable;
                                    if (record.brokerFee != null) iptRecord.mm_Broker_Fee__c = record.brokerFee;
                                    if (record.brokerFeeGST != null) iptRecord.mm_Broker_Fee_GST__c = record.brokerFeeGST;
                                    if (record.commission != null) iptRecord.mm_Comm__c = record.commission;
                                    if (record.CommFeeExGST != null) iptRecord.mm_Comm_Fee_Ex_GST__c = record.CommFeeExGST;
                                    if (record.CommissionGST != null) iptRecord.mm_Comm_GST__c = record.CommissionGST;
                                    if (record.ClosingComments != null) iptRecord.mm_Comments_on_Closing__c = record.ClosingComments;
                                    if (record.expirationDate != null) iptRecord.mm_Expiration_Date__c = Date.valueOf(record.expirationDate);
                                    if (record.FSGSuppliedDate != null) iptRecord.mm_FSG_Supplied_Date__c = Date.valueOf(record.FSGSuppliedDate);
                                    if (record.FSL != null) iptRecord.mm_FSL__c = record.FSL;
                                    if (record.GrossInsurerPremium != null) iptRecord.mm_Gross_Insurer_Premium__c = record.GrossInsurerPremium;
                                    if (record.IncomeTotal != null) iptRecord.mm_Income_Total__c = record.IncomeTotal;
                                    if (record.InsurerGST != null) iptRecord.mm_Insurer_GST__c = record.InsurerGST;
                                    if (record.InterestedParties != null) iptRecord.mm_Interested_Parties__c = record.InterestedParties;
                                    if (record.InvoiceComments != null) iptRecord.mm_Invoice_Comments__c = record.InvoiceComments;
                                    if (record.IsClosed != null) iptRecord.mm_Is_Closed__c = record.IsClosed;
                                    if (record.IsFullyPaid != null) iptRecord.mm_Is_Fully_Paid__c = record.IsFullyPaid;
                                    if (record.IsInstalmentPolicy != null) iptRecord.mm_Is_Instalment_Policy__c = record.IsInstalmentPolicy;
                                    if (record.IsLapsed != null) iptRecord.mm_Is_Lapsed__c = record.IsLapsed;
                                    if (record.IsPaid != null) iptRecord.mm_Is_Paid__c = record.IsPaid;
                                    if (record.IsPosted != null) iptRecord.mm_Is_Posted__c = record.IsPosted;
                                    if (record.PostedWhen != null) iptRecord.mm_Posted_Date__c = (DateTime)JSON.deserialize('"' + record.PostedWhen + '"', DateTime.class);
                                    if (record.IsPremiumFundingPaid != null) iptRecord.mm_Is_Premium_Funding_Paid__c = record.IsPremiumFundingPaid;
                                    if (record.IsTakeUp != null) iptRecord.mm_Is_Take_Up__c = record.IsTakeUp;
                                    if (record.Location != null) iptRecord.mm_Location__c = record.Location;
                                    if (record.InsurerName != null) iptRecord.mm_Name_Insured__c = record.InsurerName;
                                    if (record.NetCommExGST != null) iptRecord.mm_Net_Comm_Ex_GST__c = record.NetCommExGST;
                                    if (record.NetFeeExGST != null) iptRecord.mm_Net_Fee_Ex_GST__c = record.NetFeeExGST;
                                    if (record.NetIncomeTotal != null) iptRecord.mm_Net_Income_Total__c = record.NetIncomeTotal;
                                    if (record.TotalNetPremium != null) iptRecord.mm_Net_Premium__c = record.TotalNetPremium;
                                    if (record.otherCommission != null) iptRecord.mm_Other_Commission__c = record.otherCommission;
                                    if (record.otherCommissionGST != null) iptRecord.mm_Other_Commission_GST__c = record.otherCommissionGST;
                                    if (record.OtherLevy != null) iptRecord.mm_Other_Levy__c = record.OtherLevy;
                                    if (record.OtherPremium != null) iptRecord.mm_Other_Premium__c = record.OtherPremium;
                                    if (record.PDSSupplied != null) iptRecord.mm_PDS_Supplied__c = record.PDSSupplied;
                                    if (record.PDSVersion != null) iptRecord.mm_PDS_Version__c = record.PDSVersion;
                                    if (record.PolicyId != null) iptRecord.mm_Policy_Id__c = Decimal.valueOf(record.PolicyId);
                                    if (record.policyNumber != null) iptRecord.mm_Policy_Number__c = record.policyNumber;
                                    if (record.PolicyPeriodId != null) iptRecord.mm_Policy_Period_Id__c = record.PolicyPeriodId;
                                    if (record.BasePremium != null) iptRecord.mm_Premium_Amount__c = record.BasePremium;
                                    if (record.stampDuty != null) iptRecord.mm_Stamp_Duty__c = record.stampDuty;
                                    if (record.TotalARCommission != null) iptRecord.mm_Total_AR_Commission__c = record.TotalARCommission;
                                    if (record.TotalARFee != null) iptRecord.mm_Total_AR_Fee__c = record.TotalARFee;
                                    if (record.TotalBasePremium != null) iptRecord.mm_Total_Base_Premium__c = record.TotalBasePremium;
                                    if (record.TotalCommFee != null) iptRecord.mm_Total_Comm_Fee__c = record.TotalCommFee;
                                    if (record.TotalCommission != null) iptRecord.mm_Total_Commission__c = record.TotalCommission;
                                    if (record.TotalGrossPremiumExBrokerFee != null) iptRecord.mm_Total_Gross_Premium_Ex_Broker_Fee__c =record.TotalGrossPremiumExBrokerFee;
                                    if (record.TotalGST != null) iptRecord.mm_Total_GST__c = record.TotalGST;
                                    if (record.TotalLevies != null) iptRecord.mm_Total_Levies__c = record.TotalLevies;
                                    if (record.TotalNetCommFeeExGST != null) iptRecord.mm_Total_Net_Comm_Fee_Ex_GST__c = record.TotalNetCommFeeExGST;
                                    if (record.UnderwriterFee != null) iptRecord.mm_UW_Fee__c = record.UnderwriterFee;
                                    if (record.UnderwriterFeeGST != null) iptRecord.mm_UW_Fee_GST__c = record.UnderwriterFeeGST;
                                    if (record.TransactionNumber != null) iptRecord.TransactionNumber = record.TransactionNumber;
                                    if (record.TransactionTypeName != null) iptRecord.Type = record.TransactionTypeName;
                                    if (record.HasMultiClient != null) iptRecord.Has_Multipleclient__c = record.HasMultiClient;
                                    if (record.Name != null) iptRecord.name = record.TransactionNumber;
                                    iptRecord.InsurancePolicyId = policyExternalIdByPolicyId.get(String.ValueOf(record.policyId));
                                    if(record.PolicyTeamId != null && getPolicyTeamIdSF(record.PolicyTeamId) != null){
                                        iptRecord.PolicyTeamId__c = getPolicyTeamIdSF(record.PolicyTeamId);
                                    }
                                    if(record.ToDate != null){    
                                        iptRecord.mm_Expiration_Date__c = Date.valueOf(record.ToDate); 
                                    }
                                    if(record.CommFeeGST != null){
                                        iptRecord.mm_Comm_Fee_GST__c = record.CommFeeGST;
                                    }
                                    if(record.GrossInsurerPremium != null){
                                        iptRecord.mm_Gross_Written_Premium__c = record.GrossInsurerPremium;
                                    }
                                    
                                    //if exists assign id else assign mm_External_Id__c
                                    if(policyTransExternalIdByPolicyTransId.containsKey(string.valueOf(record.Id))){
                                        system.debug('policyTransExternalIdByPolicyTransId.get(string.valueOf(record.Id))->'+policyTransExternalIdByPolicyTransId.get(string.valueOf(record.Id)));
                                        iptRecord.Id = policyTransExternalIdByPolicyTransId.get(string.valueOf(record.Id));
                                    }else{
                                        system.debug('String.ValueOf(record.Id)->'+String.ValueOf(record.Id));
                                        iptRecord.mm_Insight_Record_ID__c = String.ValueOf(record.Id);
                                    }
                                    system.debug('iptRecord->'+iptRecord);
                                    PolicyTransactionListToUpsert.add(iptRecord);
                                }else{
                                    System.debug('No matching InsurancePolicy found for policyId: ' + record.policyId);
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
                log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateCreatedPolicyTransactionJson();
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getCreatedPolicyTransactionDatafromInsight';
                insert log;
            }
            if(!PolicyTransactionListToUpsert.isEmpty()){
                try{
                    Database.UpsertResult[] results  =  Database.upsert(PolicyTransactionListToUpsert, false);
                    system.debug('PolicyTransactionListToUpsert'+PolicyTransactionListToUpsert);
                    system.debug('PolicyTransactionListToUpsert'+PolicyTransactionListToUpsert.size());
                    
                    for (Integer i = 0; i < results.size(); i++) {
                        Database.UpsertResult result = results[i];
                        if (!result.isSuccess()) {
                            for (Database.Error err : result.getErrors()) {
                                mm_Integration_Log__c log = new mm_Integration_Log__c();                                    
                                if(PolicyTransactionListToUpsert[i].Id != null)
                                    log.Insurance_Policy_Transaction__c	 = PolicyTransactionListToUpsert[i].Id;
                                log.Status_Code__c   = string.valueOf(err.getStatusCode());
                                log.mm_Error_Description__c = jsonResponse;
                                log.Request_Endpoint__c = endpointPath;
                                log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateCreatedPolicyTransactionJson();                               
                                log.mm_Log_Time__c = system.now();
                                log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getCreatedPolicyTransactionDatafromInsight';
                                log.mm_Message__c = 'ErrorStatusCode  ->'+err.getStatusCode()+'\n\n ErrorMessage  ->'+err.getMessage()+'\n\n Error Fields ->'+err.getFields();
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
                    log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateCreatedPolicyTransactionJson();
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getCreatedPolicyTransactionDatafromInsight';
                    log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                    insert log;
                    
                } 
            }
        }catch(Exception ex)
        {
            System.debug('Callout Error: ' + ex.getMessage());
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateCreatedPolicyTransactionJson();
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getCreatedPolicyTransactionDatafromInsight';
            log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
            System.debug('Callout Error: ' + ex.getMessage());
        }
    }
    
    public static void getUpdatedPolicyTransactionDatafromInsight(){
        List<Insight_API_Details__c> insightAPI=Insight_API_Details__c.getAll().values();
        String endpointPath = '/PolicyTransaction/List';
        String httpMethod = 'POST'; 
        List<InsurancePolicy> IPListToInsert = new List<InsurancePolicy>();
        Set<String> policyInsightIdSet = new Set<String>();
        Set<String> policyTransactionInsightIdSet = new Set<String>();
        List<InsurancePolicy> existingInsurancePolicy = new List<InsurancePolicy>();
        List<InsurancePolicyTransaction> existingPolicyTransactionList = new List<InsurancePolicyTransaction>();
        List<InsurancePolicyTransaction> PolicyTransactionListToUpsert = new List<InsurancePolicyTransaction>();
        List<mm_Integration_Log__c> errorLogs = new List<mm_Integration_Log__c>();
        Map<String, String> transactionIdByPolicyIdMap = new Map<String, String>();
        Map<String, String> policyTransExternalIdByPolicyTransId = new Map<String, String>();
        Map<String, String> policyExternalIdByPolicyId = new Map<String, String>();
        
        HttpRequest req=new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndPoint(insightAPI[0].Insight_Endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insightAPI[0].Insight_Username__c);
        req.setHeader('INSIGHT-PASSWORD', insightAPI[0].Insight_Password__c);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(PolicyTransactionJsonBuilder.generateUpdatedPolicyTransactionJson());
        req.setTimeout(60000);
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            String jsonResponse=res.getBody();
            system.debug('res->'+res);
            if(res.getStatusCode()==200){
                system.debug('jsonResponse->'+jsonResponse);
                
                PolicyTransactionWrapper wrapper=(PolicyTransactionWrapper)JSON.deserialize(jsonResponse,PolicyTransactionWrapper.class);
                system.debug('wrapper->'+wrapper);
                
                for(PolicyTransactionWrapper.PolicyTransactionRecord record : wrapper.Results){
                    policyInsightIdSet.add(String.valueOf(record.PolicyId));
                    policyTransactionInsightIdSet.add(string.valueOf(record.Id));
                }
                System.debug('policyInsightIdSet: '+policyInsightIdSet);
                System.debug('policyTransactionInsightIdSet: '+policyTransactionInsightIdSet);
                
                if(!policyTransactionInsightIdSet.isEmpty()){
                    existingPolicyTransactionList = [SELECT Id,mm_Insight_Record_ID__c FROM InsurancePolicyTransaction WHERE mm_Insight_Record_ID__c  IN: policyTransactionInsightIdSet];
                    system.debug('existingPolicyTransactionList'+existingPolicyTransactionList);
                    
                    if(!existingPolicyTransactionList.isEmpty()){
                        for(InsurancePolicyTransaction policyTransactionRec : existingPolicyTransactionList){
                            policyTransExternalIdByPolicyTransId.put(String.valueOf(policyTransactionRec.mm_Insight_Record_ID__c), policyTransactionRec.Id);
                        }
                    }
                }
                system.debug('policyTransExternalIdByPolicyTransId'+policyTransExternalIdByPolicyTransId);
                
                if(!policyInsightIdSet.isEmpty()){
                    existingInsurancePolicy = [Select Id,mm_External_Id__c From InsurancePolicy where mm_External_Id__c IN : policyInsightIdSet];
                    system.debug('existingInsurancePolicy'+existingInsurancePolicy);
                    if(!existingInsurancePolicy.isEmpty()){
                        for(InsurancePolicy poloicyRec : existingInsurancePolicy){
                            policyExternalIdByPolicyId.put(String.valueOf(poloicyRec.mm_External_Id__c), poloicyRec.Id);
                        }               
                        system.debug('policyExternalIdByPolicyId'+policyExternalIdByPolicyId);
                        if(!policyExternalIdByPolicyId.isEmpty()){
                            for (PolicyTransactionWrapper.PolicyTransactionRecord record : wrapper.Results) {
                                system.debug('policyExternalIdByPolicyId.ContainsKey(String.ValueOf(record.policyId))->'+policyExternalIdByPolicyId.ContainsKey(String.ValueOf(record.policyId)));
                                system.debug('-----'+String.ValueOf(record.policyId));
                                if(policyExternalIdByPolicyId.ContainsKey(String.ValueOf(record.policyId))){
                                    InsurancePolicyTransaction iptRecord = new InsurancePolicyTransaction();
                                    if (record.accountId != null) iptRecord.Client_ID__c = record.accountId;
                                    if (record.EffectiveDate != null) iptRecord.mm_Effective_Date__c = record.EffectiveDate;
                                    if (record.InvoiceNumber != null) iptRecord.Invoice_Number__c = record.InvoiceNumber;
                                    if (record.ARCommission != null) iptRecord.mm_AR_Comm__c = record.ARCommission;
                                    if (record.ARCommissionGST != null) iptRecord.mm_AR_Comm_GST__c = record.ARCommissionGST;
                                    if (record.ARFee != null) iptRecord.mm_AR_Fee__c = record.ARFee;
                                    if (record.ARFeeGST != null) iptRecord.mm_AR_Fee_GST__c = record.ARFeeGST;
                                    if (record.ARTotalPayable != null) iptRecord.mm_AR_Total_Payable__c = record.ARTotalPayable;
                                    if (record.brokerFee != null) iptRecord.mm_Broker_Fee__c = record.brokerFee;
                                    if (record.brokerFeeGST != null) iptRecord.mm_Broker_Fee_GST__c = record.brokerFeeGST;
                                    if (record.commission != null) iptRecord.mm_Comm__c = record.commission;
                                    if (record.CommFeeExGST != null) iptRecord.mm_Comm_Fee_Ex_GST__c = record.CommFeeExGST;
                                    if (record.CommissionGST != null) iptRecord.mm_Comm_GST__c = record.CommissionGST;
                                    if (record.ClosingComments != null) iptRecord.mm_Comments_on_Closing__c = record.ClosingComments;
                                    if (record.expirationDate != null) iptRecord.mm_Expiration_Date__c = Date.valueOf(record.expirationDate);
                                    if (record.FSGSuppliedDate != null) iptRecord.mm_FSG_Supplied_Date__c = Date.valueOf(record.FSGSuppliedDate);
                                    if (record.FSL != null) iptRecord.mm_FSL__c = record.FSL;
                                    if (record.GrossInsurerPremium != null) iptRecord.mm_Gross_Insurer_Premium__c = record.GrossInsurerPremium;
                                    if (record.IncomeTotal != null) iptRecord.mm_Income_Total__c = record.IncomeTotal;
                                    if (record.InsurerGST != null) iptRecord.mm_Insurer_GST__c = record.InsurerGST;
                                    if (record.InterestedParties != null) iptRecord.mm_Interested_Parties__c = record.InterestedParties;
                                    if (record.InvoiceComments != null) iptRecord.mm_Invoice_Comments__c = record.InvoiceComments;
                                    if (record.IsClosed != null) iptRecord.mm_Is_Closed__c = record.IsClosed;
                                    if (record.IsFullyPaid != null) iptRecord.mm_Is_Fully_Paid__c = record.IsFullyPaid;
                                    if (record.IsInstalmentPolicy != null) iptRecord.mm_Is_Instalment_Policy__c = record.IsInstalmentPolicy;
                                    if (record.IsLapsed != null) iptRecord.mm_Is_Lapsed__c = record.IsLapsed;
                                    if (record.IsPaid != null) iptRecord.mm_Is_Paid__c = record.IsPaid;
                                    if (record.IsPosted != null) iptRecord.mm_Is_Posted__c = record.IsPosted;
                                    if (record.IsPremiumFundingPaid != null) iptRecord.mm_Is_Premium_Funding_Paid__c = record.IsPremiumFundingPaid;
                                    if (record.IsTakeUp != null) iptRecord.mm_Is_Take_Up__c = record.IsTakeUp;
                                    if (record.Location != null) iptRecord.mm_Location__c = record.Location;
                                    if (record.InsurerName != null) iptRecord.mm_Name_Insured__c = record.InsurerName;
                                    if (record.NetCommExGST != null) iptRecord.mm_Net_Comm_Ex_GST__c = record.NetCommExGST;
                                    if (record.NetFeeExGST != null) iptRecord.mm_Net_Fee_Ex_GST__c = record.NetFeeExGST;
                                    if (record.NetIncomeTotal != null) iptRecord.mm_Net_Income_Total__c = record.NetIncomeTotal;
                                    if (record.TotalNetPremium != null) iptRecord.mm_Net_Premium__c = record.TotalNetPremium;
                                    if (record.otherCommission != null) iptRecord.mm_Other_Commission__c = record.otherCommission;
                                    if (record.otherCommissionGST != null) iptRecord.mm_Other_Commission_GST__c = record.otherCommissionGST;
                                    if (record.OtherLevy != null) iptRecord.mm_Other_Levy__c = record.OtherLevy;
                                    if (record.OtherPremium != null) iptRecord.mm_Other_Premium__c = record.OtherPremium;
                                    if (record.PDSSupplied != null) iptRecord.mm_PDS_Supplied__c = record.PDSSupplied;
                                    if (record.PDSVersion != null) iptRecord.mm_PDS_Version__c = record.PDSVersion;
                                    if (record.PolicyId != null) iptRecord.mm_Policy_Id__c = Decimal.valueOf(record.PolicyId);
                                    if (record.policyNumber != null) iptRecord.mm_Policy_Number__c = record.policyNumber;
                                    if (record.PolicyPeriodId != null) iptRecord.mm_Policy_Period_Id__c = record.PolicyPeriodId;
                                    if (record.BasePremium != null) iptRecord.mm_Premium_Amount__c = record.BasePremium;
                                    if (record.stampDuty != null) iptRecord.mm_Stamp_Duty__c = record.stampDuty;
                                    if (record.TotalARCommission != null) iptRecord.mm_Total_AR_Commission__c = record.TotalARCommission;
                                    if (record.TotalARFee != null) iptRecord.mm_Total_AR_Fee__c = record.TotalARFee;
                                    if (record.TotalBasePremium != null) iptRecord.mm_Total_Base_Premium__c = record.TotalBasePremium;
                                    if (record.TotalCommFee != null) iptRecord.mm_Total_Comm_Fee__c = record.TotalCommFee;
                                    if (record.TotalCommission != null) iptRecord.mm_Total_Commission__c = record.TotalCommission;
                                    if (record.TotalGrossPremiumExBrokerFee != null) iptRecord.mm_Total_Gross_Premium_Ex_Broker_Fee__c =record.TotalGrossPremiumExBrokerFee;
                                    if (record.TotalGST != null) iptRecord.mm_Total_GST__c = record.TotalGST;
                                    if (record.TotalLevies != null) iptRecord.mm_Total_Levies__c = record.TotalLevies;
                                    if (record.TotalNetCommFeeExGST != null) iptRecord.mm_Total_Net_Comm_Fee_Ex_GST__c = record.TotalNetCommFeeExGST;
                                    if (record.UnderwriterFee != null) iptRecord.mm_UW_Fee__c = record.UnderwriterFee;
                                    if (record.UnderwriterFeeGST != null) iptRecord.mm_UW_Fee_GST__c = record.UnderwriterFeeGST;
                                    if (record.TransactionNumber != null) iptRecord.TransactionNumber = record.TransactionNumber;
                                    if (record.TransactionTypeName != null) iptRecord.Type = record.TransactionTypeName;
                                    if (record.PostedWhen != null) iptRecord.mm_Posted_Date__c = (DateTime)JSON.deserialize('"' + record.PostedWhen + '"', DateTime.class);
                                    if (record.HasMultiClient != null) iptRecord.Has_Multipleclient__c = record.HasMultiClient;
                                    if (record.Name != null) iptRecord.name = record.Name;
                                    iptRecord.InsurancePolicyId = policyExternalIdByPolicyId.get(String.ValueOf(record.policyId));
                                    if(record.PolicyTeamId != null && getPolicyTeamIdSF(record.PolicyTeamId) != null){
                                        iptRecord.PolicyTeamId__c = getPolicyTeamIdSF(record.PolicyTeamId);
                                    }
                                    if(record.ToDate != null){    
                                        iptRecord.mm_Expiration_Date__c = Date.valueOf(record.ToDate); 
                                    }
                                    if(record.CommFeeGST != null){
                                        iptRecord.mm_Comm_Fee_GST__c = record.CommFeeGST;
                                    }
                                    if(record.GrossInsurerPremium != null){
                                        iptRecord.mm_Gross_Written_Premium__c = record.GrossInsurerPremium;
                                    }
                                    
                                    //if exists assign id else assign mm_External_Id__c
                                    if(policyTransExternalIdByPolicyTransId.containsKey(string.valueOf(record.Id))){
                                        system.debug('policyTransExternalIdByPolicyTransId.get(string.valueOf(record.Id))->'+policyTransExternalIdByPolicyTransId.get(string.valueOf(record.Id)));
                                        iptRecord.Id = policyTransExternalIdByPolicyTransId.get(string.valueOf(record.Id));
                                    }else{
                                        system.debug('String.ValueOf(record.Id)->'+String.ValueOf(record.Id));
                                        iptRecord.mm_Insight_Record_ID__c = String.ValueOf(record.Id);
                                    }
                                    system.debug('iptRecord->'+iptRecord);
                                    PolicyTransactionListToUpsert.add(iptRecord);
                                }else{
                                    System.debug('No matching InsurancePolicy found for policyId: ' + record.policyId);
                                }
                            }
                        }
                    }
                }
            }else{
                // Handle API error responses
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = jsonResponse;
                log.Request_Endpoint__c = endpointPath;
                log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateUpdatedPolicyTransactionJson();
                log.mm_Log_Time__c = system.now();
                log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getUpdatedPolicyTransactionDatafromInsight';
                insert log;
            }
            if(!PolicyTransactionListToUpsert.isEmpty()){
                try{
                    Database.UpsertResult[] results  =  Database.upsert(PolicyTransactionListToUpsert, false);
                    system.debug('PolicyTransactionListToUpsert'+PolicyTransactionListToUpsert);
                    system.debug('PolicyTransactionListToUpsert'+PolicyTransactionListToUpsert.size());
                    
                    for (Integer i = 0; i < results.size(); i++) {
                        Database.UpsertResult result = results[i];
                        if (!result.isSuccess()) {
                            for (Database.Error err : result.getErrors()) {
                                mm_Integration_Log__c log = new mm_Integration_Log__c();
                                if(PolicyTransactionListToUpsert[i].Id != null)
                                    log.Insurance_Policy_Transaction__c	 = PolicyTransactionListToUpsert[i].Id;
                                log.Status_Code__c   = string.valueOf(err.getStatusCode());
                                log.mm_Error_Description__c = jsonResponse;
                                log.Request_Endpoint__c = endpointPath;
                                log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateUpdatedPolicyTransactionJson();                               
                                log.mm_Log_Time__c = system.now();
                                log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getUpdatedPolicyTransactionDatafromInsight';
                                log.mm_Message__c = 'ErrorStatusCode  ->'+err.getStatusCode()+'\n\n ErrorMessage  ->'+err.getMessage()+'\n\n Error Fields ->'+err.getFields();
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
                    log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateUpdatedPolicyTransactionJson();
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getUpdatedPolicyTransactionDatafromInsight';
                    log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                    insert log;
                } 
            }
        }
        catch(Exception ex)
        {
            System.debug('Callout Error: ----' + ex.getMessage());
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Request_Endpoint__c = endpointPath;
            log.mm_Payload__c =  'requestBody->'+PolicyTransactionJsonBuilder.generateUpdatedPolicyTransactionJson();
            log.mm_Log_Time__c = system.now();
            log.mm_Failing_Component__c = 'FetchPolicyTransactionFromInsight <-> getUpdatedPolicyTransactionDatafromInsight';
            log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
            insert log;
            System.debug('Callout Error: ' + ex.getMessage());
        }
    }
    public static string getPolicyTeamIdSF(Integer policyTeamId){
        system.debug('getPolicyTeamIdSF->   '+' policyTeamId ->'+policyTeamId );
        if(string.isBlank(String.valueOf(policyTeamId))){
            return null;
        }
        List<User> userList = new List<User>();
        if(!Test.isRunningTest()){
            userList = [Select PolicyTeamId__c,ID From User where PolicyTeamId__c =: policyTeamId limit 1];
        }else{
            userList = [Select PolicyTeamId__c,ID From User limit 1];
        }
        system.debug('userList->'+userList);
        
        if(!userList.isEmpty()){
            return userList[0].Id;
        }else{
            return null;
        }
    }
}