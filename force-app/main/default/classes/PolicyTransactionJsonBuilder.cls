/*****
* Created by Saurabh Chandra[12-06-2025]
* Test Class: FetchPolicyTransactionSchTest
* Description: This class is used to fetch the Policy Transaction Records from Insight 
* Referenced From : FetchPolicyTransactionFromInsight
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================


*/

public class PolicyTransactionJsonBuilder {

    
    public static String generateCreatedPolicyTransactionJson(){
        Map<String,Object> policyTrans=new Map<String,Object>();
        // hardcoded value for year to get some response
        string CreatedWhenFrom = (System.now().addMinutes(-15)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        string CreatedWhenTo = (System.now()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        
        policyTrans.put('CreatedWhenTo', CreatedWhenTo); 
        policyTrans.put('CreatedWhenFrom', CreatedWhenFrom); 
        system.debug('policyTrans ->'+policyTrans);
        
        return JSON.serialize(policyTrans);
    }
    public static String generateUpdatedPolicyTransactionJson(){
        Map<String,Object> policyTrans=new Map<String,Object>();
        // hardcoded value for year to get some response
        string UpdatedWhenFrom = (System.now().addMinutes(-15)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        string UpdatedWhenTo = (System.now()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        
        policyTrans.put('UpdatedWhenTo', '2025-06-16T05:01:00Z'); 
        policyTrans.put('UpdatedWhenFrom','2025-06-16T05:00:00Z'); 
        system.debug('policyTrans ->'+policyTrans);
        
        return JSON.serialize(policyTrans);
    }
}