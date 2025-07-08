public class PolicyTransactionParticipantWrapper {
    
    public Integer PolId;
    public List<ClientWrapper> Clients;
    
    public class ClientWrapper {
        public String Id;
        public String ClientName;
        public String ParentId;
        public String ClientId;
       
    }
}