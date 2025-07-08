/*****
* Created by Sunil [4-July-2025]
* Test Class: FetchPolicyTransactionExtdFromInsightTest
* Description: Gets the Policy Transaction Extended API for the policy transaction whose payments are not being processed 
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

*/

public class FetchPolicyTransactionExtdFromInsight {
    
    public static void getPolicyTransactionExtendedDatafromInsight(integer policyTransInsightId,string policyTransId){
        List<insurex__c> insurexCS=insurex__c.getAll().values();
        String endpointPath = '/PolicyTransaction/GetEx';
        String httpMethod = 'POST'; 
        List<mm_Integration_Log__c> errorLogs = new List<mm_Integration_Log__c>();
        
        HttpRequest req=new HttpRequest();
        req.setMethod(httpMethod);
        req.setEndPoint(insurexCS[0].endpoint__c+endpointPath);
        req.setHeader('INSIGHT-USERNAME', insurexCS[0].insightUsername__c);
        req.setHeader('INSIGHT-PASSWORD', insurexCS[0].insightPassword__c);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(PolicyTransCoParticipantJsonBuilder.buildRequestBody(policyTransInsightId));
        
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            system.debug('res->'+res);
            if(res.getStatusCode()==200)
            {
                String jsonResponse=res.getBody();
               // jsonResponse = jsonResponse.replaceFirst('"PolicyTransaction":\\{', '"PolicyTransaction":{"ClientLastPaidDate":"2026-06-30",');
                
                system.debug('jsonResponse->'+jsonResponse);
                Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
                Map<String, Object> outerPolicyTransactionMap = (Map<String, Object>) outerMap.get('PolicyTransaction');
                Map<String, Object> innerPolicyTransactionMap = (Map<String, Object>) outerPolicyTransactionMap.get('PolicyTransaction');
                
                InsurancePolicyTransaction iptRecord = new InsurancePolicyTransaction();
                
               if(outerPolicyTransactionMap.get('ClientLastPaidDate') != null)
               {
                    if (innerPolicyTransactionMap.get('IsFullyPaid') != null) iptRecord.mm_Is_Fully_Paid__c =(Boolean)innerPolicyTransactionMap.get('IsFullyPaid');
                    if (innerPolicyTransactionMap.get('IsPaid') != null) iptRecord.mm_Is_Paid__c =(Boolean)innerPolicyTransactionMap.get('IsPaid');
                    //if (innerPolicyTransactionMap.get('PostedWhen') != null) iptRecord.mm_Posted_Date__c =Date.valueOf((String)innerPolicyTransactionMap.get('PostedWhen'));
                    if (outerPolicyTransactionMap.get('ClientLastPaidDate') != null)iptRecord.mm_Date_Paid__c =  Date.valueOf((String)outerPolicyTransactionMap.get('ClientLastPaidDate'));
                    iptRecord.Id = policyTransId;
                    system.debug('iptRecord->'+iptRecord);
                    update iptRecord;
               }
                
            }else{
                // Handle API error responses
                mm_Integration_Log__c log = new mm_Integration_Log__c();
                log.Status_Code__c = String.valueOf(res.getStatusCode());
                log.mm_Error_Description__c = res.getStatus();
                log.mm_Payload__c = res.getBody();
                insert log;
            }
        }
        catch(Exception ex)
        {
         //   System.debug('Callout Error: ' + ex.getMessage());
            mm_Integration_Log__c log = new mm_Integration_Log__c();
            log.Status_Code__c = String.valueOf(ex.getLineNumber());
            log.mm_Error_Description__c = ex.getMessage();
            insert log;
          //  System.debug('Callout Error: ' + ex.getMessage());
        }
    }
}