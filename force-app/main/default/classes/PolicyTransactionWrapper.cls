/*****
* Created by Saurabh Chandra[12-06-2025]
* Test Class: FetchPolicyTransactionSchTest
* Description: deserialize the response from API for Policy Transaction.
* Referenced From : FetchPolicyTransactionFromInsight
* Change log
*
* Author            Date            Description
* ==============================================================================================================================================================


*/

public class PolicyTransactionWrapper {

    public List<PolicyTransactionRecord> Results;
    public Integer pageCount;
    public Integer pageNumber;
    
    public class PolicyTransactionRecord{
        public Integer Id;
        public String PolicyId;
        public String TransactionTypeName;
        public Date EffectiveDate;
        public Boolean IsInstalmentPolicy;
        public Boolean HasMultiClient;
        public String InsurerName;
        public Decimal TransactionTypeId; 
        public String TransactionNumber;
        public Decimal UnderwriterFeeGST;
        public Decimal UnderwriterFee;
        public Decimal TotalNetCommFeeExGST;
        public Decimal TotalLevies;
        public Decimal TotalGST;
        public Decimal TotalGrossPremiumExBrokerFee;
        public Decimal TotalCommission;
        public Decimal TotalCommFee;
        public Decimal TotalBasePremium;
        public Decimal TotalARFee; 
        public Decimal TotalARCommission;
        public Decimal stampDuty;
        public Decimal BasePremium; 
        public Decimal PolicyPeriodId;
        public String policyNumber;
        public String PDSVersion;
        public Boolean PDSSupplied;
        public Decimal OtherPremium;
        public Decimal OtherLevy;
        public Decimal otherCommissionGST;
        public Decimal otherCommission;
        public Decimal TotalNetPremium;
        public Decimal NetIncomeTotal;
        public Decimal NetFeeExGST;
        public Decimal NetCommExGST;
        public String Location;
        public Boolean IsTakeUp;
        public Boolean IsPremiumFundingPaid;
        public Boolean IsPosted;
        public String PostedWhen;
        public Boolean IsPaid;
        public Boolean IsLapsed;
        public Boolean IsFullyPaid;
        public Boolean IsClosed;
        public String InvoiceComments;
        public String InterestedParties;
        public Decimal InsurerGST;
        public Decimal IncomeTotal;
        public Decimal GrossInsurerPremium;
        public Decimal FSL;
        public String FSGSuppliedDate;
        public String ExpirationDate;
        public String ClosingComments;
        public Decimal CommissionGST;
        public Decimal CommFeeExGST;
        public Decimal commission;
        public Decimal brokerFeeGST;
        public Decimal brokerFee;
        public Decimal ARTotalPayable;
        public Decimal ARFeeGST;
        public Decimal ARFee;
        public Decimal ARCommissionGST;
        public Decimal ARCommission;
        Public String InvoiceNumber;
        public String accountId;
        public String Name;
        public Integer PolicyTeamId;
    }
}