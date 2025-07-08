/*****
* Created by Sunil[04-July-2025]
* Description: Calling FetchPolicyTransCoParticipantFromInsight to get Participant from Insight
* Referenced From : BatchFetchPolicyTransactionParticipants
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
*/ 
public class FetchPolicyTransExtendedInsightQue implements Queueable, Database.AllowsCallouts{
    public integer policyTransInsightId;
    public string policyTransId;
    public FetchPolicyTransExtendedInsightQue(integer policyTransInsightId,string policyTransId) {
        this.policyTransInsightId = policyTransInsightId;
        this.policyTransId = policyTransId;
    }
    public void execute(QueueableContext context) {
        FetchPolicyTransactionExtdFromInsight.getPolicyTransactionExtendedDatafromInsight(policyTransInsightId,policyTransId);
    }
}