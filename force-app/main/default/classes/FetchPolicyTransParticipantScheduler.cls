/*****
* Created by Saurabh Chandra[10-06-2025]
* Test Class: FetchPolicyTransPrtcpntSchTest
* Description: This scheduler runs in every 10 minutes to fetch the Policy Transaction Participant from Insight
* Referenced From : Scheduled
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

Abort 

List<CronTrigger> jobsToAbort = [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'FetchPolicyTransParticipantJob_%'];
for (CronTrigger job : jobsToAbort) {
System.abortJob(job.Id);
System.debug('Aborted job: ' + job.CronJobDetail.Name);
}

Schedule
for (Integer i = 0; i < 6; i++) {
Integer minutes = 7 + (i * 10); // 7, 17, 27, 37, 47, 57
String cronExp = '0 ' + minutes + ' * * * ?'; // At these minutes every hour
String jobName = 'FetchPolicyTransParticipantJob_' + minutes;
System.schedule(jobName, cronExp, new FetchPolicyTransParticipantScheduler());
}

*/
global class FetchPolicyTransParticipantScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchFetchPolicyTransactionParticipants(), 1);
    }
}