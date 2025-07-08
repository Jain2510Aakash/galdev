/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyTransactionSchTest
* Description: This class calls 2 method 1 in queuable context to get the Updated Policy Transaction from Insight and other
				is a common method to get the Created transaction records from Insight 
* Referenced From : FetchPolicyTransactionScheduler
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

*/

public class FetchCrtdPolicyTransFromInsightQueu implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        FetchPolicyTransactionFromInsight.getCreatedPolicyTransactionDatafromInsight();

        // Chain the next queuable to get the updated Policy Trans
        if(!Test.isRunningTest())
            System.enqueueJob(new FetchUpdatedPolicyTranFromInsightQue());
        
    }
}