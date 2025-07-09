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

                } catch (Exception ex) {
                    System.debug('Error converting Id to Integer: ' + ex.getMessage());
                    mm_Integration_Log__c log = new mm_Integration_Log__c();
                    log.mm_Error_Description__c = ex.getMessage();
                    log.mm_Log_Time__c = system.now();
                    log.mm_Failing_Component__c = 'BatchFetchPolicyTransactionParticipants';
                    log.mm_Message__c = 'ErrorMessage  ->'+ex.getMessage()+'\n\n Error line ->'+ex.getLineNumber()+'\n\n Stack Trace ->'+ex.getStackTraceString()+'\n\ngetCause->'+ex.getCause();
                    insert log;
                    continue;
                }
            }
        }
        
    }

    global void finish(Database.BatchableContext bc) {}
}