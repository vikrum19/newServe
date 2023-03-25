# NewServer
A simple servant server made in 2 hours


/user (GET) returns a response of "HELLO FROM THE OTHERSIDE!" message in HTML format


/user/demo (GET) returns a response "WELCOME TO THE DEMO PAGE" message in HTML format


/user?id-user=<id> (GET) returns response as user object with the given ID in JSON format


/user/<name> (GET) returns a message containing the given name in HTML format



The serverRoutes function implements the API endpoints. The first two endpoints just return text. 


Third endpoint takes a queryparam takes user id looks up users from the list of Users and returns the users object if id is matched in JSON format.If the ID is not provided in the query parameter, it returns a 400 (Bad Request) error. If no user is found with the given ID, it returns a 404 (Not Found) error.


Fourth endpoint takes a dynamic paramater /:name in the form of string and returns the strin in text format.

