/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyFromInsightTest
* Description: This class calls a common method to get the Updated policy records from Insight 
* Referenced From : FetchCreatedPolicyFromInsightQueueable
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

*/

public class FetchUpdatedPolicyFromInsightQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        FetchPolicyFromInsight.getUpdatedPolicyDatafromInsight();
    }
}