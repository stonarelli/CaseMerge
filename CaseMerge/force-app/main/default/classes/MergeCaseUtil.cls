/**
 * MergeCaseUtil - Util class to help relocate all childrens
 * @author Salesforce.com (r)
 * @date October 2017
 */
public without sharing class MergeCaseUtil {

    /**
     * Duplicate CaseComments, etc that belong to duplicated case and attach to the master Case.
     * @param dupCaseId | Duplicated case list
     * @param masterCaseId
     */
    static public void mergeCases(List<Id> dupCaseId, Id masterCaseId) {

        // Duplicate all attachments
        List<Attachment> attachmentsToBeCreated = new List<Attachment>();
        if (Schema.sObjectType.Attachment.isCreateable()){
          for (Attachment a : [SELECT Name, IsPrivate, Description, Body FROM Attachment WHERE ParentId IN :dupCaseId AND IsDeleted=false]) {
              attachmentsToBeCreated.add(new Attachment(
                  ParentId    = masterCaseId,
                  Name        = a.Name,
                  IsPrivate   = a.IsPrivate,
                  Description = a.Description,
                  Body        = a.Body
              ));
          }
        }

        // Duplicate all comments
        List<CaseComment> commentsToBeCreated = new List<CaseComment>();

        for (CaseComment cc : [SELECT IsPublished, CreatedDate, CommentBody FROM CaseComment WHERE ParentId IN :dupCaseId AND IsDeleted=false]) {
              //Only create the comment if the user has Create permissions, otherwise don't do anything
              if (Schema.sObjectType.CaseComment.isCreateable()) {
                commentsToBeCreated.add(new CaseComment(
                    ParentId    = masterCaseId,
                    IsPublished = cc.IsPublished,
                    CommentBody = cc.CommentBody
                ));
              }
        }

        if (!commentsToBeCreated.IsEmpty()){
            Database.insert(commentsToBeCreated);
        }

        // Change the whatid for all tasks
        List<Task> allTasks = [SELECT Id, WhatId FROM Task WHERE WhatId IN :dupCaseId AND IsDeleted=false];

        Map<String, Schema.SObjectField> taskFieldMap;
        taskFieldMap = Schema.getGlobalDescribe().get('task').getDescribe().fields.getMap();
        //We ask if the field WhatId of Object Task is updatable
        Boolean isTaskWhatIdUpdateable = taskFieldMap.get('WhatId').getDescribe().isUpdateable();

        //Update the Task only if WhatId is an updateable field
        if(isTaskWhatIdUpdateable) {
          if (!allTasks.isEmpty()) {
              for (integer i = 0; i < allTasks.size(); i++){
                  allTasks[i].WhatId = masterCaseId;
              }
              Database.update(allTasks);
          }
        }

        // Change the whatid for all events
        List<Event> allEvents = [SELECT Id, WhatId FROM Event WHERE WhatId IN :dupCaseId AND IsDeleted=false];

        Map<String, Schema.SObjectField> eventFieldMap;
        eventFieldMap = Schema.getGlobalDescribe().get('Event').getDescribe().fields.getMap();
        //We ask if the field WhatId of Object Event is updatable
        Boolean isEventWhatIdUpdateable = eventFieldMap.get('WhatId').getDescribe().isUpdateable();

        //Update the Event only if WhatId is an updateable field
        if(isEventWhatIdUpdateable) {
          if(!allEvents.isEmpty()) {
              for (integer i = 0; i < allEvents.size(); i++){
                  allEvents[i].WhatId = masterCaseId;
              }
              Database.update(allEvents);
          }

          // Duplicate all the attachments (of the case and related emails)
          if (!attachmentsToBeCreated.IsEmpty()){
              Database.insert(attachmentsToBeCreated);
          }
      }
    }

    /**
     * Realocate children from duplicated Cases to MasterCase
     * @param dupCaseId | Duplicated case list
     * @param masterCaseId
     */
    static public void realocateChildrens(List<Id> dupCaseId, Id masterCaseId) {

        Map<String, String> relationshipNameMap       = new Map<String, String>();
        Map<String, Schema.SObjectType> globalObjects = Schema.getGlobalDescribe();

        for(Schema.SObjectType objItem : globalObjects.values()){
            //Get the getGlobalDescribe for each object
            Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(String.valueOf(objItem)).getDescribe().fields.getMap();

            //Loop thru all object's fields
            for(String fieldItem : objectFieldMap.keySet()){
                //Get the describe for field
                Schema.DescribeFieldResult field = objectFieldMap.get(fieldItem).getDescribe();

                //Now check if it is updateable and is a referece
                if(field.isUpdateable() && String.valueOf(field.getType()).equalsIgnoreCase('REFERENCE')){
                    for(Schema.SObjectType reference : field.getReferenceTo()) {
                        if('Case'.equalsIgnoreCase(reference.getDescribe().getName())){
                            //Add the object into our map ONLY if have reference to Case
                            relationshipNameMap.put(String.valueOf(field.getLocalName()), String.valueOf(objItem));
                        }
                    }
                }
            }
        }

        //Loop thru all Ids and add it to quoteDupCaseId if isn't our masterCaseId
        List<String> quoteDupCaseId = new List<String>();
        for(String c : dupCaseId){
            if( c != masterCaseId ){
                quoteDupCaseId.add( '\'' + c + '\'' );
            }
        }

        try{
            for(String item : relationshipNameMap.keySet()){
                List<SObject> listObjs = Database.query('SELECT '+ item + ' FROM ' + relationshipNameMap.get(item) + ' WHERE '+ item + ' IN (' + String.join(quoteDupCaseId, ',') + ')');
                for(SObject obj : listObjs){
                    obj.put(item, masterCaseId);
                }
                Database.update(listObjs);
            }
        }catch(Exception e){
            throw e;
        }

        // Since we have an undetermine number of objects/objectTypes that should be query/update, we need to implement a logic to support it
        // Also, we have a limit of records in our lists (today is 50.000), it means, each list can have up to 50.000 records
        // And finally, the DML statements limit which is today 10.000
        // Now we should play with those rules, but we have an ace up your sleeve:
        // * Use Iterator interface with up to 10 records per time - give us a chance to play with undeterminate objects/objectTypes
        // * Use a Bacth to implement our Iterator - give us a chance to play with record limits either for DML or List
        //
        // Well, if we use an Iterator along with a Batch, it will run in an asynchronous process, so call it only if it's needed
        // First, get all available queies

        /*
            Integer availableQueries = Limit.getLimitQueries() - Limit.getQueries();

            // if we have enough limit to do it inside the loop, let's write some BAD PRACTICES code (I'm not happy with it) but is the only way to have results in the same thread and immediately
            if(availableQueries >= relationshipNameMap.size()){
                List<SObject> mainObjectList = new List<SObject>();
                mainObjectList.addAll(listObjs);
                //At least we can prevent DML inside Loop

            }
            // we haven't enough limit to do it inside the loop, so call the batch process
            else{

            }
        */
    }
}