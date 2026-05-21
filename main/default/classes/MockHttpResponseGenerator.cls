global class MockHttpResponseGenerator implements HttpCalloutMock {    
    global HTTPResponse respond(HTTPRequest req){
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
    }
    public static HttpResponse generateResponse(Integer statusCode, String responseBody) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseBody);
        response.setStatusCode(statusCode);
        return response;
    }    
}