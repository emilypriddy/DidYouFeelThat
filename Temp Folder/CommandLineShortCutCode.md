// Get the average data for all earthquakes in a state
// Column name passed in has to be of type Number (mag, depth, latitude, longitude, appFelt, appNotFelt, cdi, felt, tz)
curl -X POST \
  -H "X-Parse-Application-Id: PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" \
  -H "X-Parse-REST-API-Key: tQxykoEU9SThYm2munTTHaX5ThqLUItHStkxlOJK" \
  -H "Content-Type: application/json" \
  -d '{"state":"California","skip":"8000","column":"depth"}' \
  https://api.parse.com/1/functions/averageDataOfQuakesInState

// Get the number of quakes in a state based on the occurrance of that state's name in any of these columns: title, place, state
curl -X POST \
-H "X-Parse-Application-Id: PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" \
-H "X-Parse-REST-API-Key: tQxykoEU9SThYm2munTTHaX5ThqLUItHStkxlOJK" \
-H "Content-Type: application/json" \
-d '{"state":"Oklahoma","column":"place"}' \
https://api.parse.com/1/functions/numberOfQuakesWithStateNameInColumn

// You can use the limit and skip parameters for pagination. limit defaults to 100, but anything from 1 to 1000 is a valid limit. Thus, to retrieve 200 objects after skipping the first 400:
curl -X GET \
  -H "X-Parse-Application-Id: PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" \
  -H "X-Parse-REST-API-Key: tQxykoEU9SThYm2munTTHaX5ThqLUItHStkxlOJK" \
  -G \
  --data-urlencode 'limit=200' \
  --data-urlencode 'skip=400' \
  https://api.parse.com/1/classes/GameScore

// Query for all USGSQuakes in whose 'state' is equal to 'Oklahoma'
curl -X GET \
-H "X-Parse-Application-Id: PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" \
-H "X-Parse-REST-API-Key: tQxykoEU9SThYm2munTTHaX5ThqLUItHStkxlOJK" \
-G \
--data-urlencode 'order=createdAt' \
--data-urlencode 'limit=200' \
--data-urlencode 'keys=usgsId,objectId,place,mag,state,createdAt,depth,eventType,latitude,longitude,timestamp' \
--data-urlencode 'where={"state":"Oklahoma"}' \
https://api.parse.com/1/classes/USGSQuakes

// Call Cloud Function 'addCountryAndStateToQuake'
curl -X POST \
-H "X-Parse-Application-Id: PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" \
-H "X-Parse-REST-API-Key: tQxykoEU9SThYm2munTTHaX5ThqLUItHStkxlOJK" \
-H "Content-Type: application/json" \
-d '{"state":"California","country":"United States"}' \
https://api.parse.com/1/functions/addCountryAndStateToQuake

// Add a _User to the 'feltByUsers' relation of a specific USGSQuakes event (Did You Feel That? App):
curl -X PUT \
-H "X-Parse-Application-Id: PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" \
-H "X-Parse-REST-API-Key: tQxykoEU9SThYm2munTTHaX5ThqLUItHStkxlOJK" \
-H "Content-Type: application/json" \
-d '{"feltByUsers":{"__op":"AddRelation","objects":[{"__type":"Pointer","className":"_User","objectId":"m52MsMckH4"}]}}' \
https://api.parse.com/1/classes/USGSQuakes/us20003j8n

// Call Cloud Function 'getUserEventQuakes'
curl -X POST \
-H "X-Parse-Application-Id: PHtDN2GzjO0QqaWFLZ59Gcx3424kgh0oTDuqnY0Y" \
-H "X-Parse-REST-API-Key: tQxykoEU9SThYm2munTTHaX5ThqLUItHStkxlOJK" \
-H "Content-Type: application/json" \
-d '{}' \
https://api.parse.com/1/functions/getUserEventQuakes


// Add a _User to the 'feltByUsers' relation of a specific USGSQuakes event (MyParsePushApp App):
curl -X PUT 
-H "X-Parse-REST-API-Key: PO7wxU3ZiNe1sxhfGlmSo2E8VvZ4oUggjpCGdHDS" 
-H "X-Parse-Application-Id: ydgYYcs9cPs2AQNCfAwYXVD05E5S0TRg45gP9hFg" 
-H "Content-Type: application/json" 
-d '{"feltByUsers":{
	"__op":"AddRelation",
	"objects":[{
		"__type":"Pointer",
		"className":"_User",
		"objectId":"N62iShkhvF"
	}]
	}
	}' 
	https://api.parse.com/1/classes/USGSQuakes/m6tTRt3fdM


// Query for all installations:
curl -X GET \
  -H "X-Parse-Application-Id: ydgYYcs9cPs2AQNCfAwYXVD05E5S0TRg45gP9hFg" \
  -H "X-Parse-Master-Key: iHMkS4t9VFlfVc9UJFcsmdFYnrIU1lWrJSxHFtrZ" \
  https://api.parse.com/1/installations


// Query for all devices subscribed to a given push channel:
curl -X GET \
  -H "X-Parse-Application-Id: ydgYYcs9cPs2AQNCfAwYXVD05E5S0TRg45gP9hFg" \
  -H "X-Parse-Master-Key: iHMkS4t9VFlfVc9UJFcsmdFYnrIU1lWrJSxHFtrZ" \
  -G \
  --data-urlencode 'where={"channels":"us20002egs"}' \
  https://api.parse.com/1/installations 


  curl -X GET \
  -H "X-Parse-Application-Id: ydgYYcs9cPs2AQNCfAwYXVD05E5S0TRg45gP9hFg" \
  -H "X-Parse-Master-Key: iHMkS4t9VFlfVc9UJFcsmdFYnrIU1lWrJSxHFtrZ" \
  -G \
  --data-urlencode 'where={"username":"okie lover", installations":{"__type":"Pointer","className":"_Installation"}}' \
  --data-urlencode 'count=1' \
  --data-urlencode 'limit=0' \
  https://api.parse.com/1/users

curl -X GET \
  -H "X-Parse-Application-Id: ydgYYcs9cPs2AQNCfAwYXVD05E5S0TRg45gP9hFg" \
  -H "X-Parse-Master-Key: iHMkS4t9VFlfVc9UJFcsmdFYnrIU1lWrJSxHFtrZ" \
  https://api.parse.com/1/users


curl -X GET \
  -H "X-Parse-Application-Id: ydgYYcs9cPs2AQNCfAwYXVD05E5S0TRg45gP9hFg" \
  -H "X-Parse-Master-Key: iHMkS4t9VFlfVc9UJFcsmdFYnrIU1lWrJSxHFtrZ" \
  https://api.parse.com/1/users/N62iShkhvF

curl -X GET \
  -H "X-Parse-Application-Id: ydgYYcs9cPs2AQNCfAwYXVD05E5S0TRg45gP9hFg" \
  -H "X-Parse-Master-Key: iHMkS4t9VFlfVc9UJFcsmdFYnrIU1lWrJSxHFtrZ" \
  -G \
  --data-urlencode 'where={"channels":{"$exists":true}}' \
  --data-urlencode 'count=1' \
  --data-urlencode 'limit=0' \
  https://api.parse.com/1/installations/8NSebANs53