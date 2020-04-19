@isTest
private class BranchInformationScheduleTest {
    public static testmethod void scheduleBatchTest() {
        Test.startTest();
            BranchInformationSchedule testBatch = new BranchInformationSchedule();
            String sch = '0 0 0 1/1 * ? *';
            String jobId = System.schedule('Branch Schedule Job', sch, testBatch);
        Test.stopTest();
    }
}