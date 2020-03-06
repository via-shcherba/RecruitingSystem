public class ExternalConnection {

    @future(callout=true)
    public static void getExternalJobSeekers() {               
        try {                               
            ExternalData__c externalData = ExternalData__c.getOrgDefaults();
            String token = getToken(externalData);
            String operateUrl = externalData.OperationUrl__c;            
            Httprequest request = new HttpRequest();  
            request.setEndpoint(operateUrl);  
            request.setMethod('GET');                
            request.setHeader('Authorization','Bearer '+ token);                          
            HttpResponse response = new Http().send(request);     
            System.debug(response.getBody());
            String body = response.getBody().replace('\\', '').removeStart('"').removeEnd('"');            
            Map<Id , JobSeeker__c> jobSeekers = new Map<Id , JobSeeker__c>((List<JobSeeker__c>)JSON.deserialize(body, List<JobSeeker__c>.class));                      
            if (!jobSeekers.isEmpty()) {
                List<JobSeeker__c> forInsert = new List<JobSeeker__c>();               
                Set<String> specializations = new Set<String>();
                for (JobSeeker__c jobSeeker : jobSeekers.values()) {
                    if (jobSeeker.Specialization__c != null) {
                        specializations.add(jobSeeker.Specialization__c);
                    }                   
                }                
                Set<Id> existExtIds = new Set<Id>();
                for (JobSeeker__c jobSeeker : [SELECT ExtId__c 
                                               FROM JobSeeker__c 
                                               WHERE ExtId__c IN :jobSeekers.keySet()
                                               LIMIT 10000]) {
                    if (jobSeeker.ExtId__c != null) {
                        existExtIds.add(jobSeeker.ExtId__c);
                    }                   
                }                
                Map<String, Id> existSpecializations = new Map<String, Id>();
                if (!specializations.isEmpty()) {
                    for (Specialization__c specialization : [SELECT Id, Name 
                                                             FROM Specialization__c 
                                                             WHERE Name IN :specializations
                                                             LIMIT 10000]) {                        
                        existSpecializations.put(specialization.Name, specialization.Id);                                        
                    }
                }                
                for (JobSeeker__c jobSeeker : jobSeekers.values()) {
                    if (!existExtIds.contains(jobSeeker.Id)) {
                        JobSeeker__c newJobSeeker = new JobSeeker__c();
                        newJobSeeker.FirstName__c = jobSeeker.FirstName__c;
                        newJobSeeker.LastName__c = jobSeeker.LastName__c;
                        newJobSeeker.Phone__c = jobSeeker.Phone__c;
                        newJobSeeker.Email__c = jobSeeker.Email__c;
                        newJobSeeker.Background__c = jobSeeker.Background__c;
                        newJobSeeker.Specialization__c = existSpecializations.get(jobSeeker.Specialization__c);
                        newJobSeeker.ExtId__c = jobSeeker.Id;                        
                        forInsert.add(newJobSeeker);
                    }                   
                }                
                if (!forInsert.isEmpty()) {                    
                    insert forInsert;
                }
            }            
        } catch (Exception e) {
            ErrorLoger__c errorLoger = new ErrorLoger__c(
                Message__c = (String)e.getMessage(),
                Cause__c = String.valueOf(e.getCause())
            );
            insert errorLoger;
        }
    }

    private static String getToken(ExternalData__c externalData) {
        String token = '';                                                                   
        HttpRequest request = new HttpRequest();
        request.setEndpoint(externalData.AuthUrl__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(
            'grant_type=password' + 
              '&client_id=' + externalData.ClientKey__c + 
              '&client_secret=' + externalData.ClientSecret__c + 
              '&username=' + externalData.UserName__c +
              '&password=' + externalData.UserPassword__c + externalData.SecurityToken__c
           );                 
        HttpResponse res = new Http().send(request);   
        JSONParser parser = JSON.createParser(res.getBody());        
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                parser.nextToken();
                token = parser.getText();    
            } 
        }                              
        return token;
    }

}