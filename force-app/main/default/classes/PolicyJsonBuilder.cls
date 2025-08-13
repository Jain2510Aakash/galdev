/*****
* Created by Saurabh Chandra[08-06-2025]
* Test Class: FetchPolicyFromInsightTest
* Description: Creates Json body to get created and updated
* Referenced From : FetchPolicyFromInsight
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================

*/

public class PolicyJsonBuilder {
    public static String generateCreatedPolicyJson() {
        Map<String, Object> policy = new Map<String, Object>();
        // hardcoded value for year to get some response
        string CreatedWhenFrom = (System.now().addMinutes(-10)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        string CreatedWhenTo = (System.now()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        
        policy.put('CreatedWhenTo', CreatedWhenTo); 
        policy.put('CreatedWhenFrom', CreatedWhenFrom); 
        system.debug('policy->'+policy);
        
        return JSON.serialize(policy);
    }
    public static String generateUpdatedPolicyJson() {
        Map<String, Object> policy = new Map<String, Object>();
        // hardcoded value for year to get some response
        string UpdatedWhenFrom = (System.now().addMinutes(-10)).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        string UpdatedWhenTo = (System.now()).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'UTC');
        
        policy.put('UpdatedWhenTo', '2025-07-29T05:50:05Z'); 
        policy.put('UpdatedWhenFrom', '2025-07-29T05:40:05Z'); 
        system.debug('policy->'+policy);
        
        return JSON.serialize(policy);
    }
}