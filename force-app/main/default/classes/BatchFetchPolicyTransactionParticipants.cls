/*****
* Created by Saurabh Chandra[10-06-2025]
* Test Class: FetchPolicyTransPrtcpntSchTest
* Description: Gets all the PolicyTransaction records which are created or modified in salesforce within last 30 mins
* Referenced From : FetchPolicyTransParticipantScheduler
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
*/ 
global class BatchFetchPolicyTransactionParticipants implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime thirtyMinsAgo = Datetime.now().addMinutes(-30);
        String query = 'SELECT Id,mm_Insight_Record_ID__c FROM InsurancePolicyTransaction ' + 
                       'WHERE CreatedDate >= :thirtyMinsAgo ' + 
                       'OR LastModifiedDate >= :thirtyMinsAgo';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<InsurancePolicyTransaction> insurancePolicyTranList) {
        
        if(!insurancePolicyTranList.isEmpty()){
            for (InsurancePolicyTransaction policyTranRec : insurancePolicyTranList) {
                Integer policyTransInsightId = 0;
                try {
                    policyTransInsightId = Integer.valueOf(policyTranRec.mm_Insight_Record_ID__c);
                    if(policyTransInsightId != 0)
                        System.enqueueJob(new FetchPolicyTransPrtpntInsightQue(policyTransInsightId));

                } catch (Exception e) {
                    System.debug('Error converting Id to Integer: ' + e.getMessage());
                    continue;
                }
            }
        }
        
    }

    global void finish(Database.BatchableContext bc) {}
}