public class AutomoblieFormController {
    
 @AuraEnabled
    public static string updateCustom(CustomerProperty cus,Contact con) {
        
        database.update(cus);
        con.Sync_Form_Pandadoc__c = true;
        database.update(con);
    	return 'Success';
    }
    
    @AuraEnabled  
    public static contact PreFillContact()
    {
        try
        {
            string email = UserInfo.getUserEmail();
            system.debug(':::Email:'+Email);
            contact con = [select id,LastName,accountid,Email,Phone from contact where Email = :email];
            system.debug(':::con:'+con);
            
            return con;
        }
        catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
     @AuraEnabled  
    public static CustomerProperty PreFillCustomer()
    {
        try
        {
            string email = UserInfo.getUserEmail();
            
            contact con = [select id,LastName,accountid from contact where Email = :email];
            // get customer property based on contact's accountid
            ////////
            
            CustomerProperty prop = [select id,name,PrimaryOwnerId,PurchasePrice,PurchaseDate,mm_Engine_Number__c,
                                     RegistrationNumber,Vin from CustomerProperty 
                                     where PrimaryOwnerId = :con.AccountId
                                     limit 1];
            return prop;
        }
        catch(Exception ex)
        {
            throw new AuraHandledException(ex.getMessage());
        }
            
    }
   
}