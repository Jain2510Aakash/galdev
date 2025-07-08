/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyTransactionSchTest
* Description: This class calls a common method to get the Updated transaction records from Insight 
* Referenced From : FetchCrtdPolicyTransFromInsightQueu
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================


*/
public class FetchUpdatedPolicyTranFromInsightQue implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        FetchPolicyTransactionFromInsight.getUpdatedPolicyTransactionDatafromInsight();
    }
}