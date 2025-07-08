global class BatchFetchPolicyTransactionExtendedSch implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        Database.executeBatch(new BatchFetchPolicyTransactionExtended(),1);
    }
}