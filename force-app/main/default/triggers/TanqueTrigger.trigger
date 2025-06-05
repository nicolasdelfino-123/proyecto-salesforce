trigger TanqueTrigger on Tanque__c (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        TanqueHandler.handleAfterInsert(Trigger.new);
    }
}