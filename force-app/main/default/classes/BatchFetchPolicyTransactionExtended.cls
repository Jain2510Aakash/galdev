/*****
* Created by Sunil  [4-July-2025]
* Test Class: BatchFetchPolicyTransactionExtendedTest
* Description: Gets the Policy Transaction record whose payments are not being processed
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
*/ 
global class BatchFetchPolicyTransactionExtended implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'Select Id,name,CreatedDate,mm_Posted_Date__c,mm_Insight_Record_ID__c from InsurancePolicyTransaction where mm_Date_Paid__c = null AND mm_Insight_Record_ID__c != null AND mm_Posted_Date__c = LAST_90_DAYS Order By mm_Posted_Date__c ASC';
      return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<InsurancePolicyTransaction> insurancePolicyTranList) {
        
        if(!insurancePolicyTranList.isEmpty()){
            for (InsurancePolicyTransaction policyTranRec : insurancePolicyTranList) {
                Integer policyTransInsightId = 0;
                try {
                    policyTransInsightId = Integer.valueOf(policyTranRec.mm_Insight_Record_ID__c);
                    if(policyTransInsightId != 0)
                        System.enqueueJob(new FetchPolicyTransExtendedInsightQue(policyTransInsightId,policyTranRec.Id));

                } catch (Exception e) {
                    System.debug('Error converting Id to Integer: ' + e.getMessage());
                    continue;
                }
            }
        }
        
    }

    global void finish(Database.BatchableContext bc) {}
}