/*****
* Created by Saurabh Chandra[06-06-2025]
* Test Class: FetchPolicyFromInsightTest
* Description: This scheduler runs in every 10 minutes to fetch the Policy from Insight
* Referenced From : Scheduled
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================
 


For Abort 

List<CronTrigger> jobsToAbort = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'FetchPolicyScheduler_%'];
for (CronTrigger job : jobsToAbort) {
System.abortJob(job.Id);
System.debug('Aborted job: ' + job.CronJobDetail.Name);
}

For Schedule
for (Integer i = 0; i < 6; i++) {
    Integer minutes = (i * 10); // 00, 10, 20, 30, 40, 50
    String cronExp = '0 ' + minutes + ' * * * ?'; // At these minutes every hour
    String jobName = 'FetchPolicyScheduler_' + minutes;
    System.schedule(jobName, cronExp, new FetchPolicyScheduler());
}
*/
global class FetchPolicyScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new FetchCreatedPolicyFromInsightQueueable());
    }
}