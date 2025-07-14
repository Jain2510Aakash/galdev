/*****
* Created by Saurabh Chandra[03-06-2025]
* Test Class: InsightAPIHelperContactTest
* Description: Creates a JSON body to be sent for creating contact  taking reference of Contact fields
* Referenced From : InsightAPIHelperContact
* Change log
*
* Author            Date            Description
* Aakash Jain 	 	11-July-2025	handled fax and phone length
* ==============================================================================================================================================================
 
****************************************************/

public class ContactJsonBuilder {
    public static String generateContactJson(Contact con, string actionType, Integer parentId, String rowVersion) {
        Map<String, Object> contact = new Map<String, Object>();
        if(actionType == 'create'){
            contact.put('Id', 0); // For create, keep ID as 0
            contact.put('ParentId', con.Account.mm_INSIGHTS_Id__c);

        }else if(actionType == 'update'){
            contact.put('Id', con.mm_External_Id__c); // For create, keep ID as 0
            contact.put('RowVersion', rowVersion);
            contact.put('ParentId', parentId);
            contact.put('CreatedWho', con.mm_Created_Who__c);
            contact.put('CreatedWhen', con.mm_Created_When__c);
        }
        contact.put('IsPrimary', con.mm_Is_Primary_Contact__c);
        if (con.Name != null) contact.put('Addressee', con.Name);
        if (con.Salutation != null) contact.put('Salutation', con.Salutation);
        if (con.Title != null) contact.put('JobTitle', con.Title);
        if (con.OtherPhone != null) contact.put('Telephone2', con.OtherPhone);
        if (con.MobilePhone != null) contact.put('Mobile', con.MobilePhone);
        
        String phone = con.Phone != null ? con.Phone.trim() : null;
        if (phone != null) {
            phone = phone.length() > 15 ? phone.substring(0, 15) : phone;
            contact.put('Telephone', phone);
        }
        String Fax = con.Fax != null ? con.Fax.trim() : null;
        if (Fax != null) {
            Fax = Fax.length() > 15 ? Fax.substring(0, 15) : Fax;
            contact.put('Fax', Fax);
        }   
        if (con.Email != null) contact.put('Email', con.Email);
        if (con.Birthdate != null) contact.put('BirthDate', con.Birthdate);
        
        Map<String, Object> wrapper = new Map<String, Object>{'Contact' => contact};
                    
         return JSON.serialize(wrapper);
    }
}