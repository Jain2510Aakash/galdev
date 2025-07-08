public class InsightMetadataHelper {
    
    // Cache to avoid repeated SOQL calls
    private static Map<String, List<Insight_Mapping__mdt>> mappingCache;
    
    // Load metadata into cache (grouped by Object-Field key)
    private static void loadMappings() {
        mappingCache = new Map<String, List<Insight_Mapping__mdt>>();
        for (Insight_Mapping__mdt m : [
            SELECT Object_Name__c, Field_Name__c, Field_Value__c, Mapped_Id__c 
            FROM Insight_Mapping__mdt
        ]) {
            String key = m.Object_Name__c + ':' + m.Field_Name__c;
            if (!mappingCache.containsKey(key)) {
                mappingCache.put(key, new List<Insight_Mapping__mdt>());
            }
            mappingCache.get(key).add(m);
        }
    }
    
    // Public method to get Mapped ID from field value
    public static Integer getMappedId(String objectName, String fieldName, String fieldValue) {
        if (mappingCache == null) {
            loadMappings();
        }
        String key = objectName + ':' + fieldName;
        if (mappingCache.containsKey(key)) {
            for (Insight_Mapping__mdt m : mappingCache.get(key)) {
                if (m.Field_Value__c == fieldValue) {
                    return Integer.valueOf(m.Mapped_Id__c);
                }
            }
        }
        return null;
    }
    
    // Public method to get Field Value from mapped ID
    public static String getFieldValue(String objectName, String fieldName, Integer mappedId) {
        if (mappingCache == null) {
            loadMappings();
        }
        String key = objectName + ':' + fieldName;
        if (mappingCache.containsKey(key)) {
            for (Insight_Mapping__mdt m : mappingCache.get(key)) {
                if (Integer.valueOf(m.Mapped_Id__c) == mappedId) {
                    return m.Field_Value__c;
                }
            }
        }
        return null;
    }
}