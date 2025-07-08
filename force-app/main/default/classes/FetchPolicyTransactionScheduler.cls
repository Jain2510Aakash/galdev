/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyTransactionSchTest
* Description: This scheduler runs in every 10 minutes to fetch the Policy Transaction from Insight
* Referenced From : Scheduled
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

Abort 

List<CronTrigger> jobsToAbort = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'FetchPolicyTransactionScheduler_%'];
for (CronTrigger job : jobsToAbort) {
System.abortJob(job.Id);
System.debug('Aborted job: ' + job.CronJobDetail.Name);
}

Schedule
for (Integer i = 0; i < 6; i++) {
Integer minutes = 5 + (i * 10); // 5, 15, 25, 35, 45, 55
String cronExp = '0 ' + minutes + ' * * * ?'; // At these minutes every hour
String jobName = 'FetchPolicyTransactionScheduler_' + minutes;
System.schedule(jobName, cronExp, new FetchPolicyTransactionScheduler());
}

*/
global class FetchPolicyTransactionScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new FetchCrtdPolicyTransFromInsightQueu());
    }
}