require('cloud/app.js');
var _ = require('underscore');
var moment = require('cloud/moment.js');
var USGSQuakes = Parse.Object.extend("USGSQuakes");

Parse.Cloud.job('usgsJob', function(request, status) {
  	return Parse.Cloud.httpRequest({
    	url: 'http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson'
  	}).then(function(httpResponse) {
	    var jsonResponse = httpResponse.text;
	    var someJSON = JSON.parse(httpResponse.text);
	    
	    var listArray = [];
	    console.log("Running usgsJob cloud code...");
	    var thisMonth = moment().month();
	    for (var i = 0; i < someJSON.features.length; i++) {
			var usgsQuakes = new USGSQuakes();
			var item = someJSON.features[i];
			var point = new Parse.GeoPoint({latitude: item.geometry.coordinates[1], longitude: item.geometry.coordinates[0]});
			var detailURL = item.properties.detail;
			var itemCountry = "undefined";
			var itemState = "undefined";
			usgsQuakes.set("cdi", item.properties.cdi);
			usgsQuakes.set("country", itemCountry);
			usgsQuakes.set("depth", item.geometry.coordinates[2]);
			usgsQuakes.set("detailURL", item.properties.detail);
			usgsQuakes.set("eventType", item.properties.type);
			usgsQuakes.set("felt", item.properties.felt);
			usgsQuakes.set("latitude", item.geometry.coordinates[1]);
			usgsQuakes.set("location", point);
			usgsQuakes.set("longitude", item.geometry.coordinates[0]);
			usgsQuakes.set("mag", item.properties.mag);
			usgsQuakes.set("month", moment.months(thisMonth));
			usgsQuakes.set("place", item.properties.place);
			usgsQuakes.set("state", itemState);
			usgsQuakes.set("time", item.properties.time);
			usgsQuakes.set("timestamp", new Date(item.properties.time));
			usgsQuakes.set("title", item.properties.title);
			usgsQuakes.set("tz", item.properties.tz);
			usgsQuakes.set("updated", item.properties.updated);
			usgsQuakes.set("usgsCode", item.properties.code);
			usgsQuakes.set("usgsId", item.id);

			listArray.push(usgsQuakes);
	    }    		
	    var promises = [];
	    Parse.Object.saveAll(listArray, {
			success: function(objs) {
				console.log("Inside usgsJob - SAVED ALL!");
				promises.push(objs);
			},
			error: function(error){
				console.log("Inside usgsJob - ERROR WHILE SAVING - "+error);
			}
		});
	  	return Parse.Promise.when(promises);
	}).then(function() {
		// Parse.Cloud.run("fetchQuakeDetails", listArray);
	    status.success("Inside usgsJob - Saving completed successfully."); 
	}, function(error) {
	    status.error("Inside usgsJob - Uh oh, something went wrong");
	});
});

Parse.Cloud.beforeSave("USGSQuakes", function(request, response) {
	Parse.Cloud.useMasterKey();

	if(!request.object.isNew()){
		// Let existing object updates go through
		// console.log("Inside USGSQuakes.beforeSave - !request.object.isNew(). Let existing object updates go through.");
		response.success();
	}
	var query = new Parse.Query(USGSQuakes);

	// Add query filters to check for uniqueness
	query.equalTo("usgsId", request.object.get("usgsId"));
	query.first().then(function(existingObject){
		if(existingObject){
			// Update existing object
			// console.log("Inside USGSQuakes.beforeSave - if(existingObject) - Update existing object.");
			existingObject.increment("timesUpdated");
			existingObject.set("felt", request.object.get("felt"));
			existingObject.set("cdi", request.object.get("cdi"));
			existingObject.set("mag", request.object.get("mag"));
			existingObject.set("title", request.object.get("title"));
			existingObject.set("updated", request.object.get("updated"));
			existingObject.set("depth", request.object.get("d"));
			existingObject.set("latitude", request.object.get("latitude"));
			existingObject.set("longitude", request.object.get("longitude"));
			existingObject.set("eventType", request.object.get("eventType"));
			return existingObject.save();
		} else {
			// console.log("Inside USGSQuakes.beforeSave - else(!existingObject) - Parse.Promise.as(false)");
			// Pass a flag that this is not an existing object
			return Parse.Promise.as(false);
		}
	}).then(function(existingObject){
		if(existingObject){
			// Existing object, stop initial save
			// console.log("Inside USGSQuakes.beforeSave - Existing object. Stopping initial save.");
			response.error("Inside USGSQuakes.beforeSave - Existing object. Stopping initial save.");
		} else {
			// New object, let the save go through
			// Fetch the country and state (if available).
			var quakeLatitude = request.object.get("latitude");
			var quakeLongitude = request.object.get("longitude");
			var username = "emilypriddy";
		  	Parse.Cloud.httpRequest({
		    	url: "api.geonames.org/countrySubdivisionJSON?lat=" + quakeLatitude + "&lng=" + quakeLongitude + "&username=" + username
		  	}).then(function(httpResponse) {
		    	// success
			    var jsonResponse = httpResponse.text;
			    var someJSON = JSON.parse(httpResponse.text);

			    console.log("geonames request url = " + "api.geonames.org/countrySubdivisionJSON?lat=" + quakeLatitude + "&lng=" + quakeLongitude + "&username=" + username)
			    var quakeCountry = someJSON.countryName;
			    var quakeState = someJSON.adminName1;

			    request.object.set("country", quakeCountry);
			    request.object.set("state", quakeState);
			  	console.log("Set country to: " + quakeCountry + " and state to: " + quakeState + " " + httpResponse.text);
			  	// return Parse.Promise.as(false);
			  	response.success();
		  	}, function(httpResponse) {
		  	// error
		  		console.error('Request getting/setting country & state failed with response code ' + httpResponse.status);
			});
		}
	}, function(error){
		response.error("Inside USGSQuakes.beforeSave - Error performing checks or saves.");
	});
});

Parse.Cloud.afterSave("USGSQuakes", function(request) {
	Parse.Cloud.useMasterKey();

	var quake = request.object;
	var quakeLocation = quake.get('location');
	var quakeTitle = quake.get('title');
	var quakeUsgsId = quake.get('usgsId');
	var userEventRelation = quake.relation('relatedUserEvents');
	var feltByUsersRelation = quake.relation('feltByUsers');
	var pushedToUsersRelation = quake.relation('pushedToUsersRelation');
	var quakeCountry = quake.get('country');
	var quakeState = quake.get('state');
	var pushStatus = quake.get('pushSent');

	// Find all UserEvent objects that were created within 300 miles of this USGSQuakes object, have not expired (currently set to expire after 60 minutes of the creation date/time), and that have not already been assigned to a USGSQuake.
	var UserEvent = Parse.Object.extend("UserEvent");
	var userEventQuery = new Parse.Query(UserEvent);
	userEventQuery.withinMiles("userLocation", quakeLocation, 300.0);
	var userEventsArray = [];
	userEventQuery.notEqualTo("eventFound", "true");

	var d = new Date();
	var todaysDate = new Date(d.getTime());
	userEventQuery.greaterThanOrEqualTo("expirationDate", todaysDate);
	console.log("userEventQuery.greaterThanOrEqualTo = todaysDate: " + todaysDate);
	userEventQuery.find({
		success: function(userEventObjs){
			for (i=0; i < userEventObjs.length; i++){
				var userEventObj = userEventObjs[i];
				var userObj = userEventObj.get("user");
				var installationObj = userEventObj.get("installation");
				var distanceActual = (userEventObj.get("userLocation")).milesTo(quakeLocation);
				feltByUsersRelation.add(userObj);
				userEventRelation.add(userEventObj);
				userEventObj.set("eventFound", "true");
				userEventObj.set("relatedQuake", quake);
				userEventObj.set("relatedQuakeId", quake.id);
				userEventObj.set("distanceActual", distanceActual);
				userEventsArray.push(userEventObj);
			}
			Parse.Object.saveAll(userEventsArray, {
				success: function(objs) {
					console.log("Saving all userEventObjs!");
				},
				error: function(error) {
					console.log("Error saving all userEventObjs!");
				}
			});
		},
		error: function(error){
			console.log("Inside USGSQuakes.afterSave - Error finding nearby users! " + error.message);
		}
	}).then(function() {
		console.log("Inside USGSQuakes.afterSave - completed successfully!!");
	}, function(error){
		console.log("Inside USGSQuakes.afterSave - Uh oh, something went wrong! - " + error.message);
	});
	// If a push notification has not been sent out for this earthquake send one out and set the pushSent flag to true.
	if (!pushStatus || pushStatus === undefined) {
  		quake.save({
			pushSent: true
    	}, 
    	{
	    	success: function(quake) {

	    		// Push notifications for UserEvents associated with this earthquake		
	    		var pushUserEventQuery = new Parse.Query(UserEvent);
	    		pushUserEventQuery.equalTo("relatedQuakeId", quake.id);

	    		pushUserEventQuery.find().then(function(objects){
	    			var promises = [];
	    			for (i = 0; i < objects.length; i++) {
	    				var userQuery = new Parse.Query(Parse.User);
	    				var userEvent = objects[i];
	    				userQuery.equalTo("objectId", userEvent.get('user').id);
	    				var pushQuery = new Parse.Query(Parse.Installation);
	    				pushQuery.matchesQuery('user', userQuery);
	    				promises.push(Parse.Push.send({
	    					where: pushQuery,
	    					data: {
	    						alert: quakeTitle + " " + userEvent.id,
	    						badge: "Increment",
	    						category: "DidYouFeelItEventCategory",
	    						qid: quakeUsgsId
	    					}
	    				}, 
	    				{
	    					success: function(){
	    						// Push was successful!
	    						console.log("pushUserEventQuery push was successful!");
	    					},
	    					error: function(error) {
	    						// Push failed!
	    						console.error(error);
	    				}}));
	    			}
	    			return Parse.Promise.when(promises);
	    		});

	    		// Do not resend notification to users that already received notification from UserEvents push query above.
	    		

	    		// Push notifications query for all installations (users) within 250 miles of earthquake.
	    		var nearbyPushQuery = new Parse.Query(Parse.Installation);
	    		nearbyPushQuery.withinMiles("location", quakeLocation, 250);

	    		// Push notifications for users subscribed to the state (channel) in which the earthquake occured.
	    		var channelPushQuery = new Parse.Query(Parse.Installation);
	    		channelPushQuery.equalTo("channels", quakeState);

	    	}, // end success: function(quake)
	    	error: function(quake, error){
	    		// The save failed
	    		console.log("The save inside USGSQuakes.afterSave failed. " + error.message);
	    	} // end error: function(quake, error)
		}).then(function(){
			// var relatedUserEventsQuery = new Parse.Query("UserEvent");
		}); // end quake.save()
	} // end if (!pushStatus || pushStatus === undefined) {}
});

Parse.Cloud.define("getUserEventQuakes", function(request, response){
	var arrayOfQuakes = [];
	var userEventQuery = new Parse.Query("UserEvent");
	userEventQuery.exists("relatedQuake");
	userEventQuery.include("relatedQuake");
	userEventQuery.find().done(function(userEvents) {
		var userEventsGroupedByQuake = _.groupBy(userEvents, function(userEvent) {
			return userEvent.get("relatedQuake").id;
		});
		var arrayOfQuakes = _.chain(userEvents)
			.map(function(userEvent) { return userEvent.get("relatedQuake"); })
			.uniq(function(relatedQuake) { return relatedQuake.id; })
			.value();
		response.success({
			arrayOfQuakes: arrayOfQuakes,
			userEventsGroupedByQuake: userEventsGroupedByQuake
		});
	}).fail(function(error) {
		// error handle
		response.error(error.message);
	});
});

Parse.Cloud.define("addCountryAndStateToQuake", function(request, response) {
	console.log("Cloud Function addCountryAndStateToQuake with state = " + request.params.state + " country = " + request.params.country);
	var requestCountry = request.params.country;
	var requestState = request.params.state;
	var query = new Parse.Query("USGSQuakes");
	query.doesNotExist("state");
	query.contains("place", requestState);
	query.limit(500);
	query.find().then(function(results) {
		console.log("results found in addCountryAndStateToQuake: " + results.length);
		// Collect one promise for each edit into an array.
		var promises = [];
		_.each(results, function(result) {
			// Start this edit immediately and add its promise to the list.
			result.set('state', requestState);
			result.set('country', requestCountry);
			promises.push(result.save());
		});
		// Return a new promise that is resolved when all of the edits are finished.
		return Parse.Promise.when(promises);
	}).then(function() {
		// Every event was modified.
		response.success();
	});
});

Parse.Cloud.define("numberOfQuakesWithStateNameInColumn", function(request, response) {
	console.log("Cloud Function numberOfQuakesWithStateNameInColumn with state = " + request.params.state + " columnToSearch = " + request.params.column);
	var requestState = request.params.state;
	var requestColumn = request.params.column;
	var query = new Parse.Query("USGSQuakes");

	query.contains(requestColumn, requestState);
	query.count({
		success: function(number) {
			// Return the number of quakes with requestState in the place string.
			response.success(number);
		},
		error: function(error) {
			// error is an instance of Parse.Error
			response.error("Couldn't find any quakes to count!?");
		}
	});
});

Parse.Cloud.define("averageDataOfQuakesInState", function(request, response) {
	console.log("Cloud Function averageMagnitudeOfQuakesInState with state = " + request.params.state);
	var requestState = request.params.state;
	var requestData = request.params.column;
	var requestSkip = request.params.skip;
	var query = new Parse.Query("USGSQuakes");
	query.contains("state", requestState);
	query.limit(1000);
	query.skip(requestSkip);
	query.select("mag","depth","title","state","timestamp");
	query.find({
		success: function(results) {
			console.log("found " + results.length + " results in state of " + requestState);
			var sum = 0;
			for (var i = 0; i < results.length; i++) {
				sum += results[i].get(requestData);
			}
			response.success(sum / results.length);
		},
		error: function() {
			response.error("data average failed :(");
		}
	});
});

