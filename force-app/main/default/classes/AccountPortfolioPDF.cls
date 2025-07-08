public class AccountPortfolioPDF {
    public final Account account;
    public List<Opportunity> opportunities { get; private set; }
    public List<mm_Insurer_Comparison__c> insurercomparison  { get; private set; }
    public List<InsurancePolicy> insurancePolicies { get; private set; }
    public List<Case> cases { get; private set; }
    public List<Claim> claims { get; private set; }
    public List<Task> tasks {get; private set;}

    // Map to store related tasks for each claim
    public Map<Id, Boolean> hasRelatedTasks { get; private set; }
    // Map to store related IC for each Opp
    public Map<Id, Boolean> hasRelatedInsurerComparisons { get; private set; }

    //public getter for use in test class
    public Account getAccount() {
        return account;
    }

    public AccountPortfolioPDF(ApexPages.StandardController stdController) {
        Account tempAccount = (Account)stdController.getRecord();
        
        // Load the full account record with all fields we need
        this.account = [
            SELECT Id, Name, Type, Phone, mm_Account_Email__c,
            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
            User__c, User__r.Name, Account.mm_Service_Team__r.Name, Processor__r.Name, mm_Branch__c,
            Industry, mm_Nature_Of_Business__c, mm_Entity_Name__c, mm_Code__c, Parent.Name,
            UltimateParentAccount__c
            FROM Account 
            WHERE Id = :tempAccount.Id
        ];
        
        // Load related records
        loadOpportunities();
        loadInsurancePolicy();
        loadCases();
        loadClaims();
    }
    
    private void loadOpportunities() {
        
        Id renewalPolicyRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('mm_Renewal_Policy').getRecordTypeId();
        opportunities = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE AccountId = :account.Id
            AND RecordType.DeveloperName = :renewalPolicyRTId
            AND CreatedDate <= LAST_N_DAYS:730
            ORDER BY CloseDate DESC
        ];

        // Initialize IC list and opportunityHasIC map
        insurercomparison = new List<mm_Insurer_Comparison__c>();
        hasRelatedInsurerComparisons = new Map<Id, Boolean>();

        if (!opportunities.isEmpty()) {
            Set<Id> opportunityIds = new Set<Id>();
            for (Opportunity opp : opportunities) {
                opportunityIds.add(opp.Id);
                hasRelatedInsurerComparisons.put(opp.Id, false); // Default to false
            }

            // Query Insurer Comparisons related to these opportunities
            insurercomparison = [
                SELECT Id, Name, mm_Opportunity__c, Insurer__r.Name, Coverage__c, mm_Comments_Remarks__c, mm_Chosen__c
                FROM mm_Insurer_Comparison__c
                WHERE mm_Opportunity__c IN :opportunityIds
                ORDER BY Name
            ];

            // Mark opportunities that have related Insurer Comparisons
            for (mm_Insurer_Comparison__c ic : insurercomparison) {
                hasRelatedInsurerComparisons.put(ic.mm_Opportunity__c, true);
            }
        }
    }

    private void loadInsurancePolicy() {
        insurancePolicies = [
            SELECT Id, Name, mm_Transaction_Policy_Type__c, Status, Gross_Written_Premium_Roll_up__c, EffectiveDate, ExpirationDate, mm_Insurer__r.Name, ProductId, Base_Premium_Roll_up_with_in_Period__c
            FROM InsurancePolicy
            WHERE NameInsuredId = :account.Id
            AND Status = 'Active'
            ORDER BY EffectiveDate DESC
        ];
    }
    
    private void loadCases() {
        cases = [
            SELECT Id, CaseNumber, Subject, Status, Priority, CreatedDate
            FROM Case
            WHERE AccountId = :account.Id
            AND CreatedDate >= LAST_N_DAYS:730
            ORDER BY CreatedDate DESC
        ];
    }

    private void loadClaims() {
        // Query claims
        claims = [
            SELECT Id, Underwriter_Claim_Number__c, Policy__c, PolicyNumber.Name, 
                   Status, EstimatedAmount, ActualAmount, LossDate
            FROM Claim
            WHERE AccountId = :account.Id
              AND CreatedDate >= LAST_N_DAYS:730
            ORDER BY LossDate DESC
        ]; 

        // Initialize tasks list and claimHasTasks map
        tasks = new List<Task>();
        hasRelatedTasks = new Map<Id, Boolean>();
        
        if (!claims.isEmpty()) {
            Set<Id> claimIds = new Set<Id>();
            for (Claim claim : claims) {
                claimIds.add(claim.Id);
                hasRelatedTasks.put(claim.Id, false); // Default to false
            }
            
            // Query tasks related to these claims
            tasks = [
                SELECT Id, Subject, Status, Priority, ActivityDate, WhatId, Description
                FROM Task
                WHERE WhatId IN :claimIds
                ORDER BY ActivityDate DESC
            ];
            
            // Mark claims that have related tasks
            for (Task t : tasks) {
                hasRelatedTasks.put(t.WhatId, true);
            }
        }
    }
}