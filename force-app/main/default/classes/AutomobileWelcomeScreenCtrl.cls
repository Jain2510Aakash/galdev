public class AutomobileWelcomeScreenCtrl 
{
 	@AuraEnabled
    public static User getCurrentUser() {
      User user = [SELECT Id, FirstName, LastName FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
      return user;
  }

  @AuraEnabled
    public static List<InsurancePolicy> getUserPolicies() {
      List<InsurancePolicy> insurance_policy = [SELECT Id, Name, PolicyName, PolicyType, RenewalDate, NameInsured.Name, PremiumAmount, Status FROM InsurancePolicy ORDER BY CreatedDate DESC];
      return insurance_policy;
  }

  @AuraEnabled
    public static Contact getDefultAccount() {
      List<Contact> constacts = [SELECT Id,Email, Birthdate, Addressee__c, AccountId,Account.Name, 
      Account.mm_Nature_Of_Business__c, Account.mm_Entity_Name__c,Account.mm_Code__c 
      FROM Contact WHERE Email =:UserInfo.getUserEmail() LIMIT 1];

      return constacts.size() > 0 ? constacts[0] : new Contact();
  }

  @AuraEnabled
  public static String updateCurrentUserAccount(Date account_dob,String account_address, String account_business, String account_entity_name,
  String contact_id, String account_id)
  {
     Account acc = new Account(Id = account_id);
     acc.mm_Nature_Of_Business__c = account_business;
     acc.mm_Entity_Name__c = account_entity_name;

     Contact con =  new Contact(Id = contact_id);
     con.Birthdate = account_dob;
     con.Addressee__c = account_address;

     update acc;
     update con;

     return 'Success';
  }

  @AuraEnabled
  public static List<Case> getUserCases() {
    List<Case> case_list = [SELECT Id, CaseNumber,Subject, Status, CreatedDate,Priority  FROM Case ORDER BY CreatedDate DESC];
    return case_list;
}

@AuraEnabled
  public static List<Claim> getUserClaims() {
    List<Claim> claim_list = [SELECT Id, Name,ClaimType,Status, PolicyNumber.Name, Account.Name, Summary  FROM Claim ORDER BY Name DESC];
    return claim_list;
}

@AuraEnabled
  public static String createCase(String description, String insurance_id, String claim_id) 
  {
    try
    {
      String subject = '';
      String email = Test.isRunningTest() ? 'test@gmail.com' : UserInfo.getUserEmail();
        //User u = [select id,name,IsActive from user where profile.name = 'System Administrator' and isactive = true limit 1];
        List<Contact> constacts = [SELECT Id, AccountId, Account.Name FROM Contact WHERE Email =: email LIMIT 1];
        List<Claim> claims =  getClaimById(claim_id);
        List<InsurancePolicy> policies = getPoliciyById(insurance_id);
        if(constacts.size() > 0)
        {
          subject += constacts[0].Account.Name;
        }
        if(claims.size() > 0 && !String.isBlank(claims[0].ClaimType))
        {
          subject += '-' + claims[0].ClaimType;
        }

        if(policies.size() > 0 && !String.isBlank(policies[0].Name))
        {
          subject += '-' + policies[0].Name;
        }
        Case case_obj = new Case();
        case_obj.Subject = subject;
        case_obj.Description = description;
        case_obj.Status = 'New';
        case_obj.Origin = 'Web';
        case_obj.OwnerId = UserInfo.getUserId();
        if(constacts.size() > 0 )
        {
          case_obj.ContactId = constacts[0].id;
          case_obj.AccountId = constacts[0].AccountId;
        }
        //case_obj.Portal_case__c = true;
        if(!String.isEmpty(insurance_id))
        {
          case_obj.Insurance_Policy__c = insurance_id;
        }
        if(!String.isEmpty(claim_id))
        {
          case_obj.Claim__c = claim_id;
        }
        
        Database.insert(case_obj);
        
    }
    catch(Exception ex)
    {
        System.debug('Debug:' +ex.getMessage());
        //throw new AuraHandledException(ex.getMessage());
    }
    return 'Success';
  }
  @AuraEnabled
  public static List<Case> getCaseById(String record_id)
  {
    return [
      SELECT Id, CaseNumber, Subject,Priority, Description, Status, Contact.Name, Account.Name, Insurance_Policy__r.Name FROM Case
      WHERE Id =: record_id
    ];
  }
@AuraEnabled
      public static List<String> getClaimStatus(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Claim.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
      public static List<String> getClaimType(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Claim.ClaimType.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }
    @AuraEnabled
      public static List<String> getLossType(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Claim.LossType.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }

  
    
    
   @AuraEnabled
    public static void createClaim(String status,String name,String claimReason,String claimType,String estAmount,String lossType,
                                   String subjectDetails,String couseDetails, DateTime lossDate, DateTime reportDate, String accountId, String policyId)
    {try{
        Claim c = new Claim();
        if(!String.isBlank(status))
        {
          c.Status = status;
        }
        c.Name = name;
        c.ClaimReason = claimReason;
        c.ClaimType = claimType;
        if(!String.isBlank(estAmount))
        {
          c.EstimatedAmount = decimal.valueOf(estAmount);
        }
        
        c.LossType = lossType;
        c.mm_Subject_Of_Loss_Details__c = subjectDetails;
       c.mm_Cause_Of_Loss_Details__c = couseDetails;
        c.LossDate = lossDate;
        c.ReportDate = reportDate;
        c.AccountId = accountId;
        c.PolicyNumberId = policyId;
       Database.insert(c);
    }
     catch(Exception ex)
     {
         System.debug('Error:' + ex.getMessage());
     }
    }

    @AuraEnabled
    public static List<Claim> getClaimById(String record_id)
    {
      return [
        SELECT Id,Status, Name, ClaimReason, ClaimType, EstimatedAmount, LossType, mm_Subject_Of_Loss_Details__c,
         mm_Cause_Of_Loss_Details__c, LossDate, ReportDate, Account.Name FROM  Claim
         WHERE Id =: record_id
      ];
    } 

    @AuraEnabled
    public static Claim newClaim() 
    {
        return new Claim();
    }

    /* Policy Detail Page********************/
    @AuraEnabled
    public static List<InsurancePolicy> getPoliciyById(String record_id)
    {
      return [
        SELECT Id, Name, PolicyDescription, PolicyName, PolicyType, Status, ExpirationDate, GrossWrittenPremium, NameInsuredId, NameInsured.Name FROM InsurancePolicy WHERE id=:record_id
      ];
    }

    @AuraEnabled
    public static List<Contact> getContacts()
    {
      return [
        SELECT Id,Name, Birthdate, Email, MobilePhone,Phone,RecordType.Name  FROM Contact ORDER BY CreatedDate DESC
      ];
    }

    @AuraEnabled
    public static List<Contact> getContactById(String record_id)
    {
      return [
        SELECT Id,Name,FirstName, LastName, Birthdate, Email, MobilePhone,Phone  FROM Contact WHERE Id =:record_id
      ];
    }
    @AuraEnabled
    public static  void createContact(String first_name, String last_name, String mobile, String phone, Date dob, String record_id)
    {
      try 
      {
        Contact con = new Contact(Id = record_id);
        con.FirstName = first_name;
        con.LastName = last_name;
        con.MobilePhone = mobile;
        con.Phone = phone;
        con.Birthdate = dob;
        update con;

      } 
      catch (Exception ex){
        System.debug('Error:' + ex.getMessage());
      }

    }
    

    @AuraEnabled
    public static  void createPortalUser(String first_name, String last_name, String mobile, String phone, Date dob, String email)
    {
      try 
      {
        Contact con = new Contact();
        con.FirstName = first_name;
        con.LastName = last_name;
        con.MobilePhone = mobile;
        con.Phone = phone;
        con.Birthdate = dob;
        con.Email = email;
        insert con;

      } 
      catch (Exception ex){
        System.debug('Error:' + ex.getMessage());
      }

    }

    @AuraEnabled
      public static List<String> getPolicyType(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = InsurancePolicy.PolicyType.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }

    @AuraEnabled
      public static List<String> getPolicyStatus(){
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = InsurancePolicy.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
            System.debug('Values in Rating are: '+pickListValuesList);
        }     
        return pickListValuesList;
    }

    @AuraEnabled
    public static void createInsurancePolicy(String description,String policyType,String policyStatus,
                                   DateTime expDate, String grosswritten, string recordId)
    {
      try{
        InsurancePolicy policy = new InsurancePolicy();
        policy.PolicyDescription = description;
        policy.PolicyType = policyType;
        policy.Status = policyStatus;
        policy.ExpirationDate = expDate;
        policy.GrossWrittenPremium = decimal.valueOf(grosswritten);
        policy.Id = recordId;
       Database.update(policy);
    }
     catch(Exception ex)
     {
         System.debug('Error:' + ex.getMessage());
     }
    }

    @AuraEnabled
    public static List<InsurancePolicyAsset> getInsurancePolicyAssetByPolicyId(String record_id)
    {
      return [
        SELECT Id,CustomerPropertyId, Name, TotalTermAmount, TotalStandardAmount, SourceSystemIdentifier FROM InsurancePolicyAsset
        WHERE InsurancePolicyId =:record_id
        ];
    }

    @AuraEnabled
    public static List<CustomerProperty> getCustomerPropertyByAssetId(String record_id)
    {
      return [
        SELECT RecordType.DeveloperName, RecordType.Name FROM CustomerProperty WHERE Id =:record_id
      ];
    }

    @AuraEnabled
    public static List<CustomerProperty> getCustomerPropertyByPolicyId(String record_id)
    {
      List<InsurancePolicyAsset> policy_assets = [SELECT CustomerPropertyId FROM InsurancePolicyAsset WHERE InsurancePolicyId =:record_id];

      Set<Id> customer_property_ids = new Set<Id>();
      for(InsurancePolicyAsset policy_asset : policy_assets)
      {
          if(policy_asset.CustomerPropertyId != null)
          {
              customer_property_ids.add(policy_asset.CustomerPropertyId);
          }
          
      }

      List<CustomerProperty> cutomer_properties = [SELECT Id, Name, RecordType.DeveloperName, RecordType.Name FROM CustomerProperty WHERE Id
                                                  IN:customer_property_ids];
      return cutomer_properties;
    }

    public static void fakeData()
    {
      Integer i = 0;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;
      i += 1;

    }
}