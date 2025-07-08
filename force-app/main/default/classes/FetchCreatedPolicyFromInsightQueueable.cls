/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyFromInsightTest
* Description: This class calls 2 method 1 in queuable context to get the Updated Policy from Insight and other
				is a common method to get the Created Policy records from Insight 
* Referenced From : FetchPolicyScheduler
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

*/

public class FetchCreatedPolicyFromInsightQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        FetchPolicyFromInsight.getCreatedPolicyDatafromInsight();
        
        if(!Test.isRunningTest())
        // Chain the next queuable to get the updated Policy 
        System.enqueueJob(new FetchUpdatedPolicyFromInsightQueueable());

    }
}