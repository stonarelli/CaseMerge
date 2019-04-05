/**
 * CaseMergeController - extends StandardSetController to get all related cases to merge
 * @author Salesforce.com (r)
 * @date October 2017
 */
public with sharing class CaseMergeController {

    private final ApexPages.StandardSetController stdSetController;
    private final String OBJECT_NAME   = 'Case';
    private Set<String> firstFields    = new Set<String>{'id','casenumber', 'subject', 'description', 'contactid', 'Contact.Name'};
    private Set<String> excludedFields = new Set<String>{'ownerid', 'accountid'}; //Fields that will be excluded from query
    private String mergedStatus        = 'Merged - Old';
    private MergeSteps currentStep;
    private List<String> queryFields;
    private Map<String, Schema.SObjectField> objectFieldMap;
    private Id parentObjectId;
    private Schema.SObjectType parentObjectType;

    public Enum MergeSteps {CASE_SELECTION, CASE_MERGE, SUCCESS_SCREEN}
    public Map<String, List<CaseField>> itemList {get; set;}
    public transient Set<String> fieldLabels {get;set;}
    public List<CaseWrapper> relatedRecords {get;set;}
    public String errorMessage {get; set;}

    public Case masterCaseObject {get;set;}
    public List<Case> mergedCaseObjects {get;set;}

    /**
     * Public Contructor
     * @param stdSetController
     */
    public CaseMergeController(ApexPages.StandardSetController stdSetController) {
        this.stdSetController = stdSetController;
        this.init();
    }

    /**
     * Get the actual user theme and return true if user is using Lightning Experience
     * We are looking for "Theme4d", check documentation here:
     * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_userinfo.htm
     */
    public Boolean getIsLightningExperience(){
        String lightningExperienceTheme = 'Theme4d';
        return UserInfo.getUiTheme().equalsIgnoreCase(lightningExperienceTheme);
    }

    /**
     * getCaseParent Get the sobject parent (Account or Contact)
     * @return sObject
     */
    public sObject getCaseParent(){
        String caseParentField = parentObjectType + 'id';
        String quotedId        = '\'' + parentObjectId + '\'';
        String soqlQuery       = String.format('SELECT Id, Name FROM {0} WHERE Id = {1}', new String[]{String.valueOf(parentObjectType),quotedId});
        return Database.query(soqlQuery);
    }
    
    /**
     * getCaseParentType Get the sobject parent type (Account or Contact)
     * @return string
     */
    public string getCaseParentType() {
        return String.valueOf(parentObjectType);
    }

    /**
     * getCaseParentType Get the sobject parent prefix (Account or Contact)
     * @return string
     */
    public string getCaseParentPrefix() {
        return String.valueOf(parentObjectType.getDescribe().getKeyPrefix());
    }

    /**
     * nextStep evaluate the conditions and currentStep to proceed to the next step in the process if it's possible 
     * 
     */
    public void nextStep(){
        //Check first the current step
        if(currentStep == MergeSteps.CASE_SELECTION){
            //we should get all selected cases and se it on our stdcontroller
            List<sObject> selectedObjects = new List<sObject>();
            for(CaseWrapper wrapperItem : this.relatedRecords){
                if(wrapperItem.selected){
                    selectedObjects.add(wrapperItem.obj);
                }
            }
            if(!selectedObjects.isEmpty()){
                this.stdSetController.setSelected(selectedObjects);
            }
            this.init();
        }

        else if(currentStep == MergeSteps.CASE_MERGE){
            //do merge
            this.mergeRecords();
        }
    }

    /**
     * prevStep evaluate the conditions and currentStep to proceed to the previous step in the process
     * 
     */
    public void prevStep(){
        if(currentStep == MergeSteps.CASE_MERGE){
            Boolean showError = false;
            this.getCaseSelection(showError);
        }
    }

    /**
     * Used from the VFPage to determine if the PREVIOUS button should be shown
     * @return boolean
     */
    public Boolean getShowPrevButton(){
        return this.currentStep == MergeSteps.CASE_MERGE;
    }

    /**
     * Used from the VFPage to determine if the NEXT button should be shown
     * @return boolean
     */
    public Boolean getShowNextButton(){
        return  (this.currentStep == MergeSteps.CASE_MERGE && (this.itemList != null && !this.itemList.isEmpty())) ||
                (this.currentStep == MergeSteps.CASE_SELECTION && (this.relatedRecords != null && !this.relatedRecords.isEmpty()));
    }

    /**
     * Return to the view if itemList is empty
     * @return boolean
     */
    public Boolean getItemListIsEmpty(){
        return itemList == null || itemList.isEmpty();
    }

    /**
     * Return to the view if relatedRecords is empty
     * @return boolean
     */
    public Boolean getRelatedRecordsIsEmpty(){
        return relatedRecords == null || relatedRecords.isEmpty();
    }

    public String getCurrentStep(){
        return this.currentStep.name();
    }

    /**
     * Init method to evaluate if more than 1 case is selected to merge, if not, we should move the user to the Case Selection Screen
     */
    private void init(){
        this.errorMessage = '';

        //we store the parent object from where this page was called
        if (this.parentObjectId == null){
            this.parentObjectId   = ApexPages.currentPage().getParameters().get('Id');
            this.parentObjectType = parentObjectId.getSobjectType();
        }

        //If the User have selected more than 1 object, we are able to proccess selected records to display it on the page
        if(this.stdSetController.getSelected() != null && this.stdSetController.getSelected().size() > 1){
            this.processSelectedRecordsToDisplay();
        }
        //Show the Case selection step to the User with an error to enforce to select two or more cases.
        else{
            Boolean showError = true;
            this.getCaseSelection(showError);
        }
    }

    /**
     * getCaseSelection get all records from parent object
     * @param showError determine if an error should be shown in the page
     *
     */
    private void getCaseSelection(Boolean showError){
        try{
            this.currentStep    = MergeSteps.CASE_SELECTION;
            this.relatedRecords = new List<CaseWrapper>();
            String queryString  = 'SELECT Id, CaseNumber, ContactId, Subject, Priority, CreatedDate, Status, OwnerId FROM ' + OBJECT_NAME + ' WHERE {0} AND Status != :MergedStatus ORDER BY ContactId DESC';
            Schema.SObjectType parentObjectType = parentObjectId.getSobjectType();
            String caseParentField = parentObjectType + 'id';
            String whereClause = caseParentField + ' = \'' + parentObjectId + '\'';

            queryString = String.format(queryString, new String[]{whereClause});
            for(Case record: Database.query(queryString)){
                this.relatedRecords.add(new CaseWrapper(record));
            }

            if(showError || this.relatedRecords.isEmpty()){
                //Set error/info massages for both Lightning and Salesforce Clasic
                this.errorMessage = 'Please select two or more records that you wish to merge into one.';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Please select two or more records that you wish to merge into one.'));
            }

            //Finally, deselect all records from stdSetController
            this.stdSetController.setSelected(new List<sObject>());
        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.message( ApexPages.severity.ERROR, e.getDmlMessage(0) ) );
            errorMessage =  e.getDmlMessage(0);
        }catch( Exception e ){
            ApexPages.addmessage(new ApexPages.message( ApexPages.severity.ERROR, e.getMessage() ) );
            errorMessage =  e.getMessage();
        }
    }

    /**
     * processSelectedRecordsToDisplay get all selected records and fields to be shown in the page
     *
     */
    private void processSelectedRecordsToDisplay(){
        //Initialize vars :
        // - the field list to query
        // - a map of fieldName, Schema.DescribeFieldResult
        this.queryFields = new List<String>();
        Map<String, Schema.DescribeFieldResult> fieldDescribeMap = new Map<String, Schema.DescribeFieldResult>();


        //Collect all record Ids to perform the query
        List<String> recordIds = new List<String>();
        for(sObject record : this.stdSetController.getSelected()){
            recordIds.add('\'' + (String)record.get('Id') + '\'');
        }

        //Set all fields to perform the query
        //First get all fields from Case as a map and save all fields describes in fieldDescribeMap
        this.objectFieldMap = Schema.getGlobalDescribe().get(OBJECT_NAME).getDescribe().fields.getMap();

        for(String fieldName : objectFieldMap.keySet()){
            Schema.DescribeFieldResult fieldDescribe = objectFieldMap.get(fieldName).getDescribe();
            if((firstFields.contains(fieldName.toLowerCase()) || fieldDescribe.isUpdateable()) && !excludedFields.contains(fieldName.toLowerCase())){
                fieldDescribeMap.put(fieldName, fieldDescribe);
            }
        }

        //Now set first fields to have it at the top of the list
        for(String fieldName : firstFields){
            queryFields.add(fieldName);
        }

        //Finaly set the rest of the fields based on the Schema
        for(String fieldName : fieldDescribeMap.keySet()) {
            //Prevent to add the existing ones on firstFields or the excluded
            if(!firstFields.contains(fieldName.toLowerCase())){
                queryFields.add(fieldName);
            }
        }

        //Build the SOQL query string
        String soqlQuery = 'SELECT ' + String.join(queryFields, ', ') + ' FROM ' + OBJECT_NAME + ' WHERE Id IN (' + String.join(recordIds, ',') + ') AND Status != \''+mergedStatus+'\'';

        this.itemList = new Map<String, List<CaseField>>();
        this.fieldLabels = new Set<String>();

        //We need a counter to get the first fields' record selected by default
        Integer count = 0;
        for(sObject item : Database.query(soqlQuery)){

            //For each item we should build a list of CaseField
            List<CaseField> objFieldList = new List<CaseField>();

            for(String fieldName : queryFields){

                //Skip CaseNumber field, use a different value
                //if is Contact.Name, we should skip also because the relationships on Dynamic SOQL
                if(!fieldName.equalsIgnoreCase('CaseNumber') && !fieldName.equalsIgnoreCase('Contact.Name')){
                    CaseField caseFieldItem          = new CaseField();
                    caseFieldItem.apiName            = fieldName;
                    caseFieldItem.isSelectedForMerge = (count == 0);
                    caseFieldItem.realValue          = String.valueOf(item.get(fieldName));
                    caseFieldItem.renderValue        = String.valueOf(item.get(fieldName));
                    caseFieldItem.fieldLabel         = fieldName.equalsIgnoreCase('Id') ? (String)fieldDescribeMap.get('casenumber').getLabel() : (String)fieldDescribeMap.get(fieldName).getLabel();


                    //Now lets put some logic to determine the real value, the value for display and label

                    //In the Visualforce we want to shown the CaseNumber BUT keep the Id
                    if(fieldName.equalsIgnoreCase('Id')){
                        caseFieldItem.renderValue = (String)item.get('CaseNumber');
                    }

                    //If description field, we should truncate the renderValue
                    else if(fieldName.equalsIgnoreCase('Description')){
                        caseFieldItem.renderValue = truncateText((String)item.get(fieldName), 20);
                    }

                    //If subject field, we should truncate the renderValue
                    else if(fieldName.equalsIgnoreCase('Subject')){
                        caseFieldItem.renderValue = truncateText((String)item.get(fieldName), 30);
                    }

                    //If ContactId, we should shown the Contact.Name
                    else if(fieldName.equalsIgnoreCase('ContactId')){
                        //In order to get the related Contact Name we should use getSObject()
                        caseFieldItem.renderValue = (String)item.getSObject('Contact').get('Name');
                    }
                    objFieldList.add(caseFieldItem);
                    this.fieldLabels.add(caseFieldItem.fieldLabel);
                }
            }
            this.itemList.put((String)item.get('Id'), objFieldList);
            count++;
        }

        //if itemList is empty, we should back to the Case Selection 
        if(this.itemList.size() <= 1){
            this.getCaseSelection(true);
        }
        else{
            this.currentStep = MergeSteps.CASE_MERGE;
        }
    }

    /**
     * mergeRecords get all fields selected by user and start with the Merge process
     * Set the Master Case and all fields values 
     * Set the Childs Cases 
     */
    private void mergeRecords(){
        try{
            //Initialize our master object
            sObject masterObject = Schema.getGlobalDescribe().get(OBJECT_NAME).newSObject();
            String masterObjId;

            //Save parameters into a map to get code clean
            Map<String, String> fieldValuesMap = ApexPages.currentPage().getParameters();

            //convert queryFields List to Set to use contains() method
            Set<String> fieldNameSet = new Set<String>();
            fieldNameSet.addAll(this.queryFields);

            //Loop thru values to set our master object
            for(String valueItem : fieldValuesMap.keySet()){

                //Save our master object id -- workarround for id param
                if(valueItem.equalsIgnoreCase('caseId')){
                    masterObjId = fieldValuesMap.get(valueItem);
                }

                if(fieldNameSet.contains(valueItem) && this.objectFieldMap.containsKey(valueItem)){
                    String valueType = String.valueOf(this.objectFieldMap.get(valueItem).getDescribe().getType());
                    String realValue = fieldValuesMap.get(valueItem);

                    //convert value to Boolean
                    if(valueType.equalsIgnoreCase('boolean')){
                        masterObject.put(valueItem, realValue == 'true');
                    }
                    //convert value to Decimal
                    else if(valueType.equalsIgnoreCase('decimal')){
                        masterObject.put(valueItem, Decimal.valueOf(realValue));
                    }
                    //convert value to Datetime
                    else if(valueType.equalsIgnoreCase('datetime')){
                        masterObject.put(valueItem, Datetime.valueOf(realValue));
                    }
                    //String by default
                    else{
                        masterObject.put(valueItem, realValue);
                    }
                }
            }

            //We add the Master Case Id to the Object that will get updated
            masterObject.put('Id', masterObjId);

            //Obtain a List of Id from Cases that are to be merged and are not the Master Case
            List<Id> dupCasesList = this.getDupCasesList(this.itemList, masterObjId);

            //Realocate Tasks, Events, Attachments and Comments from duplicated Cases to MasterCase
            MergeCaseUtil.mergeCases(dupCasesList, masterObjId );

            //Realocate children from duplicated Cases to MasterCase
            MergeCaseUtil.realocateChildrens(dupCasesList, masterObjId);

            //We update the case with all the values selected from the Merge-Case Step.
            Database.update((Case)masterObject);

            this.updateMergedCases(dupCasesList, masterObjId);

            //Get fresh information to show in success page by query all Cases
            this.mergedCaseObjects = new List<Case>();
            for(Case item : [SELECT Id, CaseNumber, ContactId, Contact.Name, Subject, Priority, Description, Status FROM Case WHERE Id IN :this.itemList.keySet()]){
                if(item.Id == masterObjId){
                    this.masterCaseObject = item;
                }
                else{
                    this.mergedCaseObjects.add(item);
                }
            }
            this.currentStep = MergeSteps.SUCCESS_SCREEN;
            //Add success message to page
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Cases merged successfully!'));

        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.message( ApexPages.severity.ERROR, e.getDmlMessage(0) ) );
            errorMessage =  e.getDmlMessage(0);
        }catch( Exception e ){
            ApexPages.addmessage(new ApexPages.message( ApexPages.severity.ERROR, e.getMessage() ) );
            errorMessage =  e.getMessage();
        }
    }

    /**
     * truncateDescription get the Description text, check if is larger than 20 characters and truncate it
     * @param descriptionText
     * @return truncated
     */
    private static String truncateText(String descriptionText, Integer amount){
        String truncated = descriptionText;
        if(String.isNotBlank(descriptionText) && descriptionText.length() > amount){
            truncated = descriptionText.substring(0,amount) + '...';
        }
        return truncated;
    }

    /**
     * getDupCasesList get a list of Ids of all the cases to be merged, the list will not contain the master case
     * @param itemList
     * @param masterId
     * @return dupCasesList
     */
    private List<Id> getDupCasesList(Map<String, List<CaseField>> itemList ,Id masterId){
        List<Id> dupCasesList = new List<Id>();
        for (String caseId: itemList.keySet()) {
            if (caseId!= masterId){
                dupCasesList.add(caseId);
            }
        } 
        return dupCasesList;
    }

    /**
     * updateMergedCases update the status of all the cases that have been merged
     * @param dupeCasesList
     */
    private void updateMergedCases(List<Id> dupeCasesList,Id masterId){
        List<sObject> objectsToUpdate = new List<sObject>();
        for(Id caseId : dupeCasesList){
            sObject caseObj = Schema.getGlobalDescribe().get(OBJECT_NAME).newSObject();
            caseObj.put('Id',caseId);
            caseObj.put('Status', this.mergedStatus);
            caseObj.put('ParentId',masterId);
            objectsToUpdate.add(caseObj);
        }
        Database.update(objectsToUpdate);
    }

    /**
     * Wrapper class to store the field information 
     *
     */
    public class CaseField{
        public String apiName {get;set;}
        public String fieldLabel {get;set;}
        public String realValue {get;set;}
        public String renderValue {get;set;}
        public Boolean isSelectedForMerge {get;set;}
    }

    /**
     * Wrapper class to get Cases at the case selection stage
     *
     */
    public class CaseWrapper{
        public Boolean selected {get;set;}
        public Case obj {get;set;}

        public CaseWrapper(Case caseObj){
            this.obj         = caseObj;
            this.obj.Subject = truncateText(this.obj.Subject, 30);
            this.selected    = false;
        }
    }
}