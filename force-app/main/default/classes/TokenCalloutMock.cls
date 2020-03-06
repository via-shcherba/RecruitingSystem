global with sharing class TokenCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {		
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		String jsonData = '[{\"Id\":\"a002w0000035KZqAAM\",\"Background__c\":\"I am a good man\",\"Email__c\":\"smak@were.here\",\"FirstName__c\":\"Kiril\",\"LastName__c\":\"Smaktunovskiy\",\"Phone__c\":\"5559678\",\"Specialization\":\"Apex\"}]';
		response.setBody(jsonData);
		response.setStatusCode(200);
		return response; 
	}

}
