global class BranchInformationSchedule implements Schedulable {
    global void execute(System.SchedulableContext sc) { 
        GetBranchInformationBatch batchSch = new GetBranchInformationBatch();
        Database.executeBatch(batchSch, 100);
    }
}