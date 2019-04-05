@isTest
private class CaseMergeControllerTest{
    
    @isTest
    public static void testValidateCaseMergeController () {
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account where Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.stopTest();
        
        System.assertNotEquals( null ,caseMerge, 'Controller could not be constructed');
    }
    
    @isTest
    public static void testgetIsLightningExperience () {
        Boolean isLightningTheme = UserInfo.getUiTheme().equalsIgnoreCase('Theme4d');
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        
        Test.startTest();
        Boolean resultController = caseMerge.getIsLightningExperience();
        Test.stopTest();
        
        System.assertEquals(isLightningTheme ,resultController, 'IsLightningExperience not ');
    }
    
    @isTest
    public static void testParentIsAccount () {
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        String parentType = caseMerge.getCaseParentType();
        Test.stopTest();
        
        String expectedResult = 'Account';
        System.assertEquals(expectedResult ,parentType, 'Parent is not of type Account');
    }
    
    @isTest
    public static void testParentIsContact () {
        createTestCases(2,0);
        Contact tempContact = [SELECT Id FROM Contact WHERE LastName = 'LastNameTest'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE ContactId =:tempContact.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempContact.Id));
        Test.setCurrentPage(pageRef);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        String parentType = caseMerge.getCaseParentType();
        Test.stopTest();
        
        String expectedResult = 'Contact';
        System.assertEquals(expectedResult ,parentType, 'Parent is not of type Contact');
    }
    
    @isTest
    public static void testgetCaseParent () {
        createTestCases(2,0);
        Contact tempContact = [SELECT Id FROM Contact WHERE LastName = 'LastNameTest'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE ContactId =:tempContact.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempContact.Id));
        Test.setCurrentPage(pageRef);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        sObject controllerResult = caseMerge.getCaseParent();
        Test.stopTest();
        
        sObject expectedResult = [SELECT Id, Name FROM CONTACT WHERE Id = :tempContact.Id];
        System.assertEquals(expectedResult ,controllerResult, 'Result does not match the expected object');
    }
    
    @isTest
    public static void testgetCaseParentPrefix () {
        createTestCases(2,0);
        Contact tempContact = [SELECT Id FROM Contact WHERE LastName = 'LastNameTest'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE ContactId =:tempContact.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempContact.Id));
        Test.setCurrentPage(pageRef);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        string controllerResult = caseMerge.getCaseParentPrefix();
        Test.stopTest();
        
        String expectedResult = '003';
        System.assertEquals(expectedResult ,controllerResult, 'Result does not match the expected result');
    }
    
    @isTest
    public static void testNoCaseSelected () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_SELECTION);
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        String controllerResult = caseMerge.getCurrentStep();
        Test.stopTest();
        
        String expectedResult = 'Please select two or more records that you wish to merge into one.';
        System.assertEquals(expectedResult ,caseMerge.errorMessage, 'Error message does not match as there should be no case selected ');
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
        
    }
    @isTest
    public static void testOneCaseSelected () {
        
        createTestCases(4,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        List<Case> selectedCaseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id LIMIT 1];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(selectedCaseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_SELECTION);
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        String controllerResult = caseMerge.getCurrentStep();
        Test.stopTest();
        
        String expectedResult = 'Please select two or more records that you wish to merge into one.';
        System.assertEquals(expectedResult ,caseMerge.errorMessage, 'Error message does not match as there should be no case selected ');
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    @isTest
    public static void testMergedCaseSelected () {
        createTestCases(0,2);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        List<Case> selectedCaseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id AND Status != 'Merged - Old'];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(selectedCaseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_SELECTION);
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        String controllerResult = caseMerge.getCurrentStep();
        Test.stopTest();
        
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    @isTest
    public static void testValidCaseSelected () {
        
        createTestCases(2,2);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        List<Case> selectedCaseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id AND Status != 'Merged - Old'];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(selectedCaseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_MERGE);
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        String controllerResult = caseMerge.getCurrentStep();
        Test.stopTest();
        
        String expectedResult = 'Please select two or more records that you wish to merge into one.';
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    @isTest
    public static void testMultipleCaseSelected () {
        
        createTestCases(100,100);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_MERGE);
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        String controllerResult = caseMerge.getCurrentStep();
        Test.stopTest();
        
        String expectedResult = 'Please select two or more records that you wish to merge into one.';
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    @isTest
    public static void testOneMergedOneNewCaseSelected () {
        
        createTestCases(1,1);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_SELECTION);
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        String controllerResult = caseMerge.getCurrentStep();
        Test.stopTest();
        
        String expectedResult = 'Please select two or more records that you wish to merge into one.';
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    @isTest
    public static void testprevStep () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        pageRef.getParameters().put('Caseid', String.valueOf(caseList[0].Id));
        pageRef.getParameters().put('description','value of description to be merged, this is more than 20 so it should be truncated');
        pageRef.getParameters().put('Subject','value of description to be merged, this is more than 20 so it should be truncated');
        
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_SELECTION);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        caseMerge.prevStep();
        Test.stopTest();
        
        String controllerResult = caseMerge.getCurrentStep();
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    @isTest
    public static void testNextStepInCaseSelection () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id,Subject FROM CASE WHERE AccountId =:tempAccount.Id];
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.CASE_MERGE);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        for(Case record: caseList){
            CaseMergeController.CaseWrapper tempCase = new CaseMergeController.CaseWrapper(record);
            tempCase.Selected = true;
            caseMerge.relatedRecords.add(tempCase);
        }
        Test.startTest();
        caseMerge.nextStep();
        Test.stopTest();
        
        String controllerResult = caseMerge.getCurrentStep();
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    @isTest
    public static void testgetShowPrevButton () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id,Subject FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        Boolean expectedResult = true;
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        Boolean controllerResult = caseMerge.getShowPrevButton();
        Test.stopTest();
        
        System.assertEquals(expectedResult ,controllerResult, 'Button should be show');
    }
    
    @isTest
    public static void testgetShowNextButton () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id,Subject FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        Boolean expectedResult = true;
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        Boolean controllerResult = caseMerge.getShowNextButton();
        Test.stopTest();
        
        System.assertEquals(expectedResult ,controllerResult, 'Button should be show');
    }
    
    @isTest
    public static void testgetShowNextButtonInCaseSelection () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id,Subject FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        Boolean expectedResult = true;
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        caseMerge.prevStep();
        Test.startTest();
        Boolean controllerResult = caseMerge.getShowNextButton();
        Test.stopTest();
        
        System.assertEquals(expectedResult ,controllerResult, 'Button should be show');
    }
    
    @isTest
    public static void testgetItemListIsEmpty () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id,Subject FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        Boolean expectedResult = true;
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.startTest();
        Boolean controllerResult = caseMerge.getItemListIsEmpty();
        Test.stopTest();
        
        System.assertEquals(expectedResult ,controllerResult, 'Item List should be empty');
    }
    
    @isTest
    public static void testgetRelatedRecordsIsEmpty () {
        
        createTestCases(0,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id,Subject FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        Test.setCurrentPage(pageRef);
        Boolean expectedResult = true;
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        caseMerge.prevStep();
        Test.startTest();
        Boolean controllerResult = caseMerge.getRelatedRecordsIsEmpty();
        Test.stopTest();
        
        System.assertEquals(expectedResult ,controllerResult, 'Related records should be empty');
    }
    
    @isTest
    public static void testgetCaseSelectionError () {
        
        createTestCases(0,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id,Subject FROM CASE WHERE AccountId =:tempAccount.Id];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', '0061I0000014GEJQA2');
        Test.setCurrentPage(pageRef);
        String expectedResult = 'No such column \'Opportunityid\' on entity \'Case\'. If you are attempting to use a custom field, be sure to append the \'__c\' after the custom field name. Please reference your WSDL or the describe call for the appropriate names.';
        Test.startTest();
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        Test.stopTest();
        
        System.assertEquals(expectedResult ,caseMerge.errorMessage, 'The exception error does not match');
    }
    
    @isTest
    public static void testMergeErrorCircularParent() {
        
        createTestCases(3,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        caseList[0].ParentId=caseList[1].Id;
        caseList[2].ParentId=caseList[0].Id;
        update caseList;
        
        List<Case> selectedCase = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id LIMIT 2];
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        pageRef.getParameters().put('Caseid', String.valueOf(caseList[0].Id));
        pageRef.getParameters().put('description','value of description to be merged, this is more than 20 so it should be truncated');
        pageRef.getParameters().put('Subject','value of description to be merged, this is more than 20 so it should be truncated');
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.SUCCESS_SCREEN);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        String expectedResult =  'This case is parented by a case that is also its child.';
        Test.startTest();
        caseMerge.nextStep();
        Test.stopTest();
        
        String controllerResult = caseMerge.getCurrentStep();
        System.assertEquals(expectedResult ,caseMerge.errorMessage, 'The exception error does not match');
    }
    
    @isTest
    public static void testMergeSuccessfull () {
        
        createTestCases(2,0);
        Account tempAccount = [SELECT Id FROM Account WHERE Name = 'AccountTestName'];
        List<Case> caseList = [SELECT Id FROM CASE WHERE AccountId =:tempAccount.Id];
        createTestAttachments(caseList[1].Id, 2);
        createTestEvents(caseList[1].Id, 2);
        createTestTasks(caseList[1].Id, 2);
        createCaseComments(caseList[1].Id, 2);
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(caseList);
        stdSetController.setSelected(caseList);
        PageReference pageRef = Page.CaseMerge;
        pageRef.getParameters().put('id', String.valueOf(tempAccount.Id));
        pageRef.getParameters().put('Caseid', String.valueOf(caseList[0].Id));
        pageRef.getParameters().put('description','value of description to be merged, this is more than 20 so it should be truncated');
        pageRef.getParameters().put('Subject','value of description to be merged, this is more than 20 so it should be truncated');
        
        Test.setCurrentPage(pageRef);
        String expectedStep = String.valueOf(CaseMergeController.MergeSteps.SUCCESS_SCREEN);
        CaseMergeController caseMerge = new CaseMergeController(stdSetController);
        
        Test.startTest();
        caseMerge.nextStep();
        Test.stopTest();
        
        String controllerResult = caseMerge.getCurrentStep();
        System.assertEquals(expectedStep ,controllerResult, 'Step mismatch');
    }
    
    
    
    private static void createTestAttachments(Id caseId, Integer numberOfAttachments){
        List<Attachment> attachments=new List<Attachment>();
        for (Integer x=0; x<=numberOfAttachments-1;x++) {
            Attachment attach=new Attachment();
            attach.Name='Unit Test Attachment ' + x ;
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body '+ x);
            attach.body=bodyBlob;
            attach.parentId=caseId;
            attachments.add(attach);
        }
        insert attachments;
    }
    
    private static void createTestEvents(Id caseId, Integer numberOfAttachments){
        List<Event> events=new List<Event>();
        for (Integer x=0; x<=numberOfAttachments-1;x++) {
            Event tempEvent = new Event();
            tempEvent.Type = 'Email';
            tempEvent.Description = 'Event for test ' + x; //string
            tempEvent.DurationInMinutes =10;
            tempEvent.ActivityDateTime= datetime.now();
            
            tempEvent.OwnerId = UserInfo.getUserId(); //user id
            tempEvent.WhatId = caseId; //record id
            events.add(tempEvent);
        }
        insert events;
    }
    
    private static void createTestTasks(Id caseId, Integer numberOfTasks){
        List<Task> tasks=new List<Task>();
        for (Integer x=0; x<=numberOfTasks-1;x++) {
            Task tempTask = new Task();
            tempTask.Type = 'Email';
            tempTask.Description = 'Task for test ' + x; //string
            tempTask.OwnerId = UserInfo.getUserId(); //user id
            tempTask.WhatId = caseId; //record id
            tasks.add(tempTask);
        }
        insert tasks;
    }
    private static void createCaseComments(Id caseId, Integer numberOfComments){
        List<CaseComment> comments=new List<CaseComment>();
        for (Integer x=0; x<=numberOfComments-1;x++) {
            CaseComment comment = new CaseComment();
            comment.CommentBody = 'Test Case Comment ' + x;
            comment.ParentId = caseId;
            comments.add(comment);
        }
        insert comments;
    }
    
    private static void createTestCases(Integer numberOfCases, Integer numberOfOldCases)
    {
        Account tempAccount = new Account();
        tempAccount.Name = 'AccountTestName';
        insert tempAccount;
        
        Contact tempContact = new Contact();
        tempContact.LastName =  'LastNameTest';
        insert tempContact;
        
        List<Case> caseList = new List<Case>();
        
        for (Integer x=0; x<=numberOfCases-1;x++) {
            Case tempCase= new Case();
            tempCase.status = 'New';
            tempCase.ContactId = tempContact.Id;
            tempCase.AccountId = tempAccount.Id;
            tempCase.Subject = 'test case New number: '+ x ;
            tempCase.Description = 'value of description to be merged, this is more than 20 so it should be truncated';
            caseList.add(tempCase);
        }
        
        for (Integer x=0; x<=numberOfOldCases-1;x++) {
            Case tempCase= new Case();
            tempCase.status = 'Merged - Old';
            tempCase.ContactId = tempContact.Id;
            tempCase.AccountId = tempAccount.Id;
            tempCase.Subject = 'test case Merged number: '+ x;
            caseList.add(tempCase);
        }
        
        insert caseList;
    }
}