/*****
* Created by Saurabh Chandra[10-06-2025]
* Test Class: FetchPolicyTransPrtcpntSchTest
* Description: Calling FetchPolicyTransCoParticipantFromInsight to get Participant from Insight
* Referenced From : BatchFetchPolicyTransactionParticipants
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
*/ 
public class FetchPolicyTransPrtpntInsightQue implements Queueable, Database.AllowsCallouts{
    public integer policyTransInsightId;
    
    public FetchPolicyTransPrtpntInsightQue(integer policyTransInsightId) {
        this.policyTransInsightId = policyTransInsightId;
    }
    public void execute(QueueableContext context) {
        FetchPolicyTransCoParticipantFromInsight.getPolicyTransactionParticipantDatafromInsight(policyTransInsightId);
    }
}