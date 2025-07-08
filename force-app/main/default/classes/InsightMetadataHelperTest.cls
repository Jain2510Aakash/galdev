@isTest
private class InsightMetadataHelperTest {

    @isTest(seeAllData=true)
    static void testGetMappedId() {
        // Since we cannot insert CMDT directly in Apex test, using seeAllData=true (if allowed)
        // Alternative: mock the metadata using stubs or rely on existing CMDT values.

        Test.startTest();
        Integer result = InsightMetadataHelper.getMappedId('Account', 'Type', 'Customer');
        Test.stopTest();

    }

    @isTest(seeAllData=true)
    static void testGetFieldValue() {
        Test.startTest();
        String fieldValue = InsightMetadataHelper.getFieldValue('Account', 'Type', 1001);
        Test.stopTest();

    }

    @isTest(seeAllData=true)
    static void testGetMappedId_NotFound() {
        Integer result = InsightMetadataHelper.getMappedId('Account', 'State', 'ACL');
    }

    @isTest(seeAllData=true)
    static void testGetFieldValue_NotFound() {
        String value = InsightMetadataHelper.getFieldValue('Account', 'State', 1);
    }
}