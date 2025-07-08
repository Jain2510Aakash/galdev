public class PolicyTransCoParticipantJsonBuilder {
    
    public static String buildRequestBody(integer policyId) {
        Map<String, Object> policyTransParticipant = new Map<String, Object>();
        policyTransParticipant.put('Id', policyId);
        
        return JSON.serialize(policyTransParticipant);
        
    }
}